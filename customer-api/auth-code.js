const { PublicClientApplication } = require('@azure/msal-node');
require('dotenv').config();

const msalConfig = {
    auth: {
        clientId: process.env.AZURE_CLIENT_ID,
        authority: 'https://login.microsoftonline.com/consumers', // Personal accounts only
        redirectUri: 'http://localhost:3000/auth',
    },
};

const pca = new PublicClientApplication(msalConfig);

async function generateAuthUrl() {
    try {
        const authUrl = await pca.getAuthCodeUrl({
            scopes: ['User.Read'], // Microsoft Graph permission
            redirectUri: 'http://localhost:3000/auth',
        });

        console.log('Visit this URL to authenticate:', authUrl);
    } catch (err) {
        console.error('Error generating auth URL:', err);
    }
}

generateAuthUrl();
