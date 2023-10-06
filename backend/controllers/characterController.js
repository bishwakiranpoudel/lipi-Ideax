const Jimp = require('jimp');
const potrace = require('potrace');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

module.exports = (bucket, db) => {
  function processImage(imageFile) {
    return new Promise((resolve, reject) => {
      const potraceOptions = {
        turdsize: 0.5,      
        opttolerance: 0.05,
      };

      Jimp.read(imageFile.buffer)
        .then((image) => {
          let characterLeft = image.bitmap.width;
          let characterRight = 0;
  
          // Find the bounding box of the character
          for (let x = 0; x < image.bitmap.width; x++) {
            for (let y = 0; y < image.bitmap.height; y++) {
              const pixelColor = image.getPixelColor(x, y);
  
              // Check if the pixel is not transparent (alpha channel is not 0)
              if (Jimp.intToRGBA(pixelColor).a !== 0) {
                if (x < characterLeft) {
                  characterLeft = x;
                }
                if (x > characterRight) {
                  characterRight = x;
                }
              }
            }
          }
  
          // Crop the image
          const croppedImage = image.crop(
            characterLeft - 2,
            0,
            characterRight - characterLeft + 2,
            image.bitmap.height
          );
  
          // Save the cropped image to a temporary file
          const tempOutputFile = `temp_output_${uuidv4()}.png`;
          croppedImage.write(tempOutputFile, () => {
            const imageWidth = croppedImage.bitmap.width;
  
            potrace.trace(croppedImage.bitmap, potraceOptions, (potraceErr, svg) => {
              if (potraceErr) {
                reject(potraceErr);
              } else {
                const modifiedSvg = svg.replace(
                  /<svg[^>]*>/,
                  `<svg width="${imageWidth}" viewBox="0 0 ${imageWidth} ${croppedImage.bitmap.height}">`
                );
  
                fs.writeFileSync(tempOutputFile, modifiedSvg);
  
                // Upload the modified SVG to Firebase Storage
                const svgPath = `images/${uuidv4()}.svg`;
                const svgFile = bucket.file(svgPath);
                const svgStream = svgFile.createWriteStream();
  
                svgStream.on('error', (svgUploadError) => {
                  reject(svgUploadError);
                });
  
                svgStream.on('finish', () => {
                  svgFile.getSignedUrl({ action: 'read', expires: '01-01-2030' }, (svgUrlErr, svgUrl) => {
                    if (svgUrlErr) {
                      reject(svgUrlErr);
                    } else {
                      // Resolve the SVG URL
                      resolve(svgUrl);
  
                      // Delete the temporary cropped image file from your system
                      fs.unlink(tempOutputFile, (deleteError) => {
                        if (deleteError) {
                          console.error('Error deleting temporary image file:', deleteError);
                        } else {
                          console.log('Temporary image file deleted successfully.');
                        }
                      });
                    }
                  });
                });
  
                svgStream.end(fs.readFileSync(tempOutputFile));
              }
            });
          });
        })
        .catch((error) => {
          reject(error);
        });
    });
  }

  const uploadCharacter = async (req, res) => {
    const { unicode, languageID } = req.body;
    console.log('languageID:', languageID); // Extract unicode and languageID from the request body

    // Handle image and audio processing and upload
    processImage(req.files.find(file => file.fieldname === 'image'))
      .then((svgPath) => {
        // Handle audio upload
        const audioPath = `audio/${uuidv4()}.mp3`;

        const audioFile = bucket.file(audioPath);
        const audioStream = audioFile.createWriteStream();

        audioStream.on('error', (error) => {
          console.error('Error uploading audio:', error);
          res.status(500).send('Error uploading audio');
        });

        audioStream.on('finish', () => {
          audioFile.getSignedUrl({ action: 'read', expires: '01-01-2030' }, (audioUrlErr, audioUrl) => {
            if (audioUrlErr) {
              console.error('Error generating audio download URL:', audioUrlErr);
              res.status(500).send('Error generating audio download URL');
            } else {
              // Store the download links in Firestore
              const characterRef = db
                .collection('languages')
                .doc(languageID)
                .collection('characters')
                .doc(); // Create a new Firestore document within the character collection

              characterRef
                .set({ image: svgPath, audio: audioUrl, unicode, languageID })
                .then(() => {
                  console.log('Data stored in Firestore successfully.');
                  res.status(200).json({ image: svgPath, audio: audioUrl });
                })
                .catch((firestoreError) => {
                  console.error('Error storing data in Firestore:', firestoreError);
                  res.status(500).send('Error storing data in Firestore');
                });
            }
          });
        });

        audioStream.end(req.files.find(file => file.fieldname === 'audio').buffer);
      })
      .catch((error) => {
        console.error('Error processing image:', error);
        res.status(500).send('Error processing image');
      });
  };

  return {
    uploadCharacter,
  };
};