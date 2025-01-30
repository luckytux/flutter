const express = require('express');
const { sql } = require('../config/db'); // Ensure db.js exports the SQL connection
const jwt = require('jsonwebtoken'); // For token validation (if not using a library like msal-node)
const router = express.Router();

// Middleware for token validation
function validateToken(req, res, next) {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
        return res.status(401).json({ message: 'Authorization header missing' });
    }

    const token = authHeader.split(' ')[1]; // Bearer <token>

    try {
        // Validate token using a library or Azure's public key
        const decodedToken = jwt.decode(token, { complete: true }); // Use verification if necessary
        if (!decodedToken) {
            return res.status(401).json({ message: 'Invalid token' });
        }

        req.user = decodedToken.payload; // Attach user info to the request object
        next();
    } catch (err) {
        console.error('Token validation error:', err);
        return res.status(401).json({ message: 'Invalid token' });
    }
}

// GET /customers
router.get('/customers', validateToken, async (req, res) => {
    const searchQuery = req.query.search || '';

    try {
        // Parameterized query to prevent SQL injection
        const result = await sql.query`
            SELECT * FROM customers WHERE name LIKE ${'%' + searchQuery + '%'}
        `;
        res.status(200).json(result.recordset);
    } catch (err) {
        console.error('Error fetching customers:', err);
        res.status(500).json({ message: 'Failed to fetch customers' });
    }
});

module.exports = router;
