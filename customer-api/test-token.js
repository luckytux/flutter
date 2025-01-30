const { PublicClientApplication } = require('@azure/msal-node');
require('dotenv').config(); // Load environment variables from .env file

// MSAL Configuration
const msalConfig = {
    auth: {
        clientId: process.env.AZURE_CLIENT_ID, // ScaleWrite App Client ID from .env
        authority: 'https://login.microsoftonline.com/consumers', // Endpoint for personal accounts
        redirectUri: 'http://localhost:3000/auth', // Redirect URI configured in Azure
    },
};

// Initialize Public Client Application
const pca = new PublicClientApplication(msalConfig);

// Function to acquire token using authorization code
async function acquireToken() {
    const authCode = 'M.C510_BL2.2.U.58d426f5-eb4b-3266-c5c7-66321911aaf0'; // Replace this with your latest authorization code

    try {
        const tokenResponse = await pca.acquireTokenByCode({
            code: authCode, // Use the auth code obtained from auth-code.js
            scopes: ['User.Read'], // Basic Microsoft Graph scope
            redirectUri: 'http://localhost:3000/auth', // Ensure it matches your MSAL config
        });

        // Print the access token to the console
        console.log('Access Token:', tokenResponse.accessToken);
    } catch (err) {
        // Log any errors encountered
        console.error('Error acquiring token:', err);
    }
}

// Call the function to acquire token
acquireToken();
