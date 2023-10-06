const csvWriter = require("csv-writer").createObjectCsvWriter;
const jsonfile = require("jsonfile");
const fs = require("fs");
const axios = require("axios");
const path = require("path");
const { createGzip } = require("zlib");
const { pipeline } = require("stream");
const { promisify } = require("util");
const pipelineAsync = promisify(pipeline);
const archiver = require("archiver");
const admin = require("firebase-admin");

module.exports = {
    generateZip: async (bucket, db, req, res) => {
      try {
        const languageID = req.query.languageID;
        const collectionRef = db.collection("languages").doc(languageID).collection("words");
        const documents = await collectionRef.get();
  
        const csvData = [];
        const jsonData = [];
  
        documents.forEach((doc) => {
          const data = doc.data();
          const row = {
            Native: data.native || "",
            Meaning: data.meaning || "",
            English: data.english || "",
          };
          csvData.push(row);
  
          const jsonRow = {
            Native: data.native || "",
            Meaning: data.meaning || "",
            English: data.english || "",
            AudioFileName: `audio/${data.native}.mp3` || "",
          };
          jsonData.push(jsonRow);
        });
  
        const datasetsDir = "datasets";
        if (!fs.existsSync(datasetsDir)) {
          fs.mkdirSync(datasetsDir);
        }
  
        const csvFilePath = path.join(datasetsDir, "data.csv");
        const jsonFilePath = path.join(datasetsDir, "data.json");
        const audioDir = path.join(datasetsDir, "audio");
  
        const csvWriterInstance = csvWriter({
          path: csvFilePath,
          header: [
            { id: "Native", title: "Native" },
            { id: "Meaning", title: "Meaning" },
            { id: "English", title: "English" },
          ],
        });
  
        await csvWriterInstance.writeRecords(csvData);
  
        jsonfile.writeFileSync(jsonFilePath, jsonData);
  
        if (!fs.existsSync(audioDir)) {
          fs.mkdirSync(audioDir);
        }
  
        const downloadPromises = [];
  
        documents.forEach((doc) => {
          const data = doc.data();
          const audioLink = data.audio;
          const audioFileName = data.native + ".mp3";
          const audioFilePath = path.join(audioDir, audioFileName);
  
          const downloadPromise = axios
            .get(audioLink, { responseType: "stream" })
            .then((response) => {
              if (response.status === 200) {
                const fileStream = fs.createWriteStream(audioFilePath);
                response.data.pipe(fileStream);
                console.log(`Downloaded audio from: ${audioLink}`);
              } else {
                console.error(`Failed to download audio from: ${audioLink}`);
              }
            })
            .catch((axiosError) => {
              console.error(`Error downloading audio from ${audioLink}: ${axiosError.message}`);
            });
  
          downloadPromises.push(downloadPromise);
        });
  
        await Promise.all(downloadPromises);
  
        const zipFileName = "data.zip";
        const zipFilePath = path.join(__dirname, zipFileName); // Full path for local ZIP file
        console.log(`Path to data.zip: ${zipFilePath}`);
  
        const archive = archiver("zip", { zlib: { level: 9 } });
        const output = fs.createWriteStream(zipFilePath);
  
        archive.pipe(output);
        archive.directory(datasetsDir, false);
        await archive.finalize();
  
        console.log(`ZIP archive created: ${zipFilePath}`);
        // Set the appropriate headers to allow everyone to access the file
        res.setHeader("Content-Disposition", `attachment; filename=${zipFileName}`);
        res.setHeader("Content-Type", "application/zip");
        // Upload the ZIP file to Firebase Storage with the same path
        const storagePath = `dataset/${zipFileName}`; // Specify the Firebase Storage path
        const storage = bucket.file(storagePath);
        const zipFileData = await fs.promises.readFile(zipFilePath);
        await storage.save(zipFileData);
  
        // Get the download URL for the uploaded ZIP file
        const [url] = await storage.getSignedUrl({
          action: "read",
          expires: '01-01-2050',  // URL expires in 24 hours
        });
  
        // Add the current date to the Firestore document
        const currentDate = new Date();
        const languageRef = db.collection("languages").doc(languageID);
        const datasetsCollectionRef = languageRef.collection("datasets");
        await datasetsCollectionRef.add({ downloadLink: url, date: currentDate });
  

        res.sendFile(zipFilePath, {}, (err) => {
          if (err) {
            console.error(`Error sending file: ${err.message}`);
          } else {
            fs.unlinkSync(zipFilePath); // Clean up the file after sending
          }
        });
      } catch (error) {
        console.error(error);
        res.status(500).send("Internal Server Error");
      }
    },
  };
