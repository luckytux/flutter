const express = require('express');
const jwt = require('jsonwebtoken');
const sql = require('mssql');
const { ConfidentialClientApplication } = require('@azure/msal-node');
require('dotenv').config();

const app = express();
app.use(express.json());

// MSAL Configuration
const msalConfig = {
    auth: {
        clientId: process.env.AZURE_CLIENT_ID, // ScaleWrite Backend Client ID
        authority: `https://login.microsoftonline.com/${process.env.AZURE_TENANT_ID}`,
        clientSecret: process.env.AZURE_CLIENT_SECRET,
    },
};

// Initialize MSAL Client
const msalClient = new ConfidentialClientApplication(msalConfig);

// Azure SQL Configuration
const dbConfig = async () => {
    const tokenResponse = await msalClient.acquireTokenByClientCredential({
        scopes: ['https://database.windows.net/.default'],
    });

    return {
        server: process.env.DB_SERVER,
        database: process.env.DB_DATABASE,
        authentication: {
            type: 'azure-active-directory-access-token',
            options: {
                token: tokenResponse.accessToken,
            },
        },
        options: {
            encrypt: true,
            trustServerCertificate: false,
        },
    };
};

// Token Validation Middleware
function validateToken(req, res, next) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).send('Access token missing or malformed');
    }

    const token = authHeader.split(' ')[1];
    console.log('Raw Token:', token); // Log the raw token for debugging

    try {
        // Decode the token
        const decoded = jwt.decode(token, { complete: true });
        console.log('Decoded Token:', decoded); // Log the decoded token for inspection

        // Validate issuer and audience
        if (decoded.payload.iss !== 'https://login.microsoftonline.com/consumers/v2.0') {
            throw new Error('Invalid token issuer');
        }
        if (decoded.payload.aud !== process.env.AZURE_CLIENT_ID) {
            throw new Error('Invalid token audience');
        }

        req.user = decoded.payload; // Attach user claims to request
        next();
    } catch (err) {
        console.error('Token validation failed:', err.message);
        res.status(401).send(`Token validation failed: ${err.message}`);
    }
}

// Example Route: Fetch Customers from Database
app.get('/customers', validateToken, async (req, res) => {
    try {
        const config = await dbConfig();
        const pool = await sql.connect(config);

        const result = await pool.request().query('SELECT * FROM customers');
        res.json(result.recordset);
    } catch (err) {
        console.error('Database error:', err);
        res.status(500).send('Database query failed');
    }
});

// Start Server
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
    console.log(`Backend server running on http://localhost:${PORT}`);
});
