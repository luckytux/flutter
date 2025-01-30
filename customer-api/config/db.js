const sql = require('mssql');
const { ConfidentialClientApplication } = require('@azure/msal-node');
require('dotenv').config();

const config = {
    auth: {
        clientId: process.env.AZURE_CLIENT_ID,
        authority: `https://login.microsoftonline.com/${process.env.AZURE_TENANT_ID}`,
        clientSecret: process.env.AZURE_CLIENT_SECRET,
    },
    database: {
        server: process.env.DB_SERVER,
        database: process.env.DB_DATABASE,
        options: {
            encrypt: true,
            trustServerCertificate: false,
        },
    },
};

const msalClient = new ConfidentialClientApplication({
    auth: config.auth,
});

async function connectToDB() {
    try {
        const tokenResponse = await msalClient.acquireTokenByClientCredential({
            scopes: ['https://database.windows.net/.default'],
        });

        const dbConfig = {
            server: config.database.server,
            database: config.database.database,
            authentication: {
                type: 'azure-active-directory-access-token',
                options: {
                    token: tokenResponse.accessToken,
                },
            },
            options: config.database.options,
        };

        await sql.connect(dbConfig);
        console.log('Connected to Azure SQL with Entra Authentication');
    } catch (err) {
        console.error('Error connecting to Azure SQL:', err);
        throw err;
    }
}

module.exports = { sql, connectToDB };
