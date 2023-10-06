const express = require('express');
const admin = require('firebase-admin');
const multer = require('multer');
const app = express();
const port = 3000;

// Initialize Firebase Admin SDK
const serviceAccount = require('./serviceAccountKey.json'); 
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'gs://lipi-b8642.appspot.com',
});

//Firebase storage
const bucket = admin.storage().bucket();
const db = admin.firestore(); // Initialize Firestore





// Multer storage configuration for file uploads
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

app.use(express.json());

// Define routes

const characterRoutes = require('./routes/characterRoutes')(bucket, upload, db);
app.use('/api/characters', characterRoutes);

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});