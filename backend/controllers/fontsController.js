const axios = require('axios');
const fs = require('fs');
const path = require('path');
const svgicons2svgfont = require('svgicons2svgfont');
const svg2ttf = require('svg2ttf');

module.exports = (bucket, db) => {
    function deleteFolderRecursive(directoryPath) {
        if (fs.existsSync(directoryPath)) {
          if (fs.statSync(directoryPath).isDirectory()) {
            fs.readdirSync(directoryPath).forEach((file) => {
              const currentPath = path.join(directoryPath, file);
      
              if (fs.statSync(currentPath).isDirectory()) {
                // Recursively delete subdirectories
                deleteFolderRecursive(currentPath);
              } else {
                // Delete file
                fs.unlinkSync(currentPath);
              }
            });
            // Delete the empty directory
            fs.rmdirSync(directoryPath);
          } else {
            fs.unlinkSync(directoryPath);
          }
        }
      }

  async function getJSON(id) {
    const collectionRef = db.collection('languages').doc(id).collection('characters');
    const iconMappings = [];
    const downloadPromises = [];

    const snapshot = await collectionRef.get();

    snapshot.forEach((doc) => {
      data = doc.data();
      url = data.image;
      const folderPath = `./${id}`;

      if (!fs.existsSync(folderPath)) {
        fs.mkdirSync(folderPath, { recursive: true });
      }

      const fileName = path.join(folderPath, `${doc.id}.svg`);

      const downloadPromise = axios.get(url, { responseType: 'stream' })
        .then((response) => {
          return new Promise((resolve, reject) => {
            response.data.pipe(fs.createWriteStream(fileName))
              .on('finish', () => {
                console.log(`Downloaded: ${fileName}`);
                resolve();
              })
              .on('error', (error) => {
                console.error('Failed', error.message);
                reject(error);
              });
          });
        });

      downloadPromises.push(downloadPromise);

      const object = { name: `${doc.id}`, unicode: data.unicode };
      iconMappings.push(object);
    });

    // Wait for all download promises to complete before logging iconMappings
    await Promise.all(downloadPromises);

    console.log(iconMappings);
    await generateSvgFont(iconMappings, id);

    return `output${id}/font.ttf`;
  }
  const generateSvgFont = async (iconMappings, id) => {
    return new Promise((resolve, reject) => {
      const fontStream = new svgicons2svgfont({
        fontName: 'MyFont',
        normalize: true,
        horizAdvX: 30,
      });
  
      fontStream.pipe(fs.createWriteStream('font.svg'))
        .on('finish', async () => {
          console.log('SVG font generated successfully');
          try {
            const ttfFilePath = await convertSvgFontToTtf(id);
            resolve(ttfFilePath);
          } catch (err) {
            reject(err);
          }
        });
  
      iconMappings.forEach((mapping) => {
        const glyph = fs.createReadStream(`./${id}/${mapping.name}.svg`);
        if (mapping.name === 'space') {
          // For the space character, set fill to 'none'
          glyph.metadata = {
            name: mapping.name,
            unicode: [String.fromCharCode(32)],
            fill: 'none',
            horizAdvX: mapping.horizAdvX || 250,
          };
          if (mapping.horizAdvX) {
            glyph.metadata['horiz-adv-x'] = mapping.horizAdvX;
          }
        } else {
          glyph.metadata = { name: mapping.name, unicode: [String.fromCharCode(mapping.unicode.charCodeAt(0))] };
        }
        if (mapping.horizAdvX) {
          glyph.metadata.horizAdvX = mapping.horizAdvX;
        }
        fontStream.write(glyph);
      });
  
      fontStream.end();
    });
  };
  
  // Convert SvgFont to .ttf file format 
  const convertSvgFontToTtf = async (id) => {
    return new Promise((resolve, reject) => {
      const svgFont = fs.readFileSync('font.svg', 'utf8');
      const ttfFont = svg2ttf(svgFont, {});
  
      // Create the 'output' directory if it doesn't exist
      if (!fs.existsSync(`output${id}`)) {
        fs.mkdirSync(`output${id}`);
      }
  
      const ttfFilePath = `output${id}/font.ttf`;
  
      fs.writeFileSync(ttfFilePath, new Uint8Array(ttfFont.buffer));
      console.log('SVG font converted to TTF successfully');
      resolve(ttfFilePath);
    });
  };
  
  const createFont = async (req, res) => {
    const languageID = req.query.languageID;
  
    if (!languageID) {
      return res.status(400).json({ error: 'languageID is required in the request body' });
    }
  
    try {
      // Generate the SVG font and convert it to TTF
      const ttfFilePath = await getJSON(languageID);
  
      // Check if the TTF font file exists
      if (!fs.existsSync(ttfFilePath)) {
        console.error(`TTF font file not found at ${ttfFilePath}`);
        return res.status(500).send('TTF font file not found');
      }
  
      // Continue with the upload and Firestore updates
      const localPath = ttfFilePath;
      const storageFilePath = `fonts/${languageID}.ttf`;
  
      bucket.upload(localPath, {
        destination: storageFilePath,
      })
        .then((response) => {

          console.log('File uploaded successfully');
          var fontUrl;

          const file = bucket.file(`fonts/${languageID}.ttf`); // Replace with the path to your file in Firebase Storage

file.getSignedUrl({
  action: 'read',
  expires: '01-01-2024', // Set an expiration date for the link
})
  .then(signedUrls => {
    const downloadUrl = signedUrls[0];
    console.log('Download URL:', downloadUrl);
    fontUrl=downloadUrl;
    documentRef= db.collection('languages').doc(languageID);
    documentRef
            .update({ 'font': fontUrl })
            .then(() => {
              console.log('Document updated successfully');
            })
            .catch((error) => {
              console.error('Error updating document:', error);
            });

            const fontRef = db.collection('languages').doc(languageID).collection('fonts').doc();
            fontRef
              .set({ file: fontUrl, date: new Date() })
              .then(() => {
                console.log('Data stored in Firestore successfully');
    
                // Clean up resources after successful upload
                deleteFolderRecursive(`./${languageID}`);
                deleteFolderRecursive(ttfFilePath);
                fs.unlinkSync('font.svg');
    
                res.status(200).json({ file: fontUrl, date: new Date() });
              })
              .catch((firestoreError) => {
                console.error('Error storing data in Firestore:', firestoreError);
                res.status(500).send('Error storing data in Firestore');
              });
    
  })
  .catch(error => {
    console.error('Error generating download URL:', error);
  });        
        })
        .catch((error) => {
          console.error('Error uploading file:', error);
          res.status(500).send('Error uploading file to Firebase Storage');
        });
    } catch (error) {
      console.error('Error generating and uploading font:', error);
      res.status(500).send('Error generating and uploading font');
    }
  };

  return {
    createFont,
  };
};
