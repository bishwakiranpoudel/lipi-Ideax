const express = require('express');
const router = express.Router();

module.exports = (bucket, db) => {
  // Import the character controller
  const datasetController = require('../controllers/datasetController');

  router.post('/generatedataset', (req, res) => {
    datasetController.generateZip(bucket, db, req, res);
  });

  return router;
};
