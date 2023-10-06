const express = require('express');
const router = express.Router();

module.exports = (bucket, upload, db) => {
  // Import the character controller
  const characterController = require('../controllers/characterController')(bucket, db);

  // Define the route handlers
  router.post('/upload', upload.any(), characterController.uploadCharacter);

  return router;
};