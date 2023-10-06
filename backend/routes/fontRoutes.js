const express = require('express');
const router = express.Router();

module.exports = ( bucket, db) => {
    const fontController = require('../controllers/fontsController')(bucket, db); 
    
    router.post('/create', fontController.createFont);

    return router;
};