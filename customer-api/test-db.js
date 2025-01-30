const sql = require('mssql');
const { ConfidentialClientApplication } = require('@azure/msal-node');
require('dotenv').config();

// MSAL Configuration
const msalConfig = {
    auth: {
        clientId: process.env.AZURE_CLIENT_ID,
        authority: `https://login.microsoftonline.com/${process.env.AZURE_TENANT_ID}`,
        clientSecret: process.env.AZURE_CLIENT_SECRET,
    },
};

// Database Configuration
async function connectToDB() {
    const msalClient = new ConfidentialClientApplication(msalConfig);
    try {
        // Acquire token for Azure SQL
        const tokenResponse = await msalClient.acquireTokenByClientCredential({
            scopes: ['https://database.windows.net/.default'],
        });
        console.log('Access Token acquired:', tokenResponse.accessToken);

        // Database connection config with token
        const dbConfig = {
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

        // Connect to the database
        const pool = await sql.connect(dbConfig);
        console.log('Connected to Azure SQL Database');

        // Test query
        const result = await pool.request().query('SELECT TOP 1 * FROM customers');
        console.log('Test query result:', result.recordset);

        sql.close();
    } catch (err) {
        console.error('Error connecting to database:', err);
    }
}

connectToDB();
