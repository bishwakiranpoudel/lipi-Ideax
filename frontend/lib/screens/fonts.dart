import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FontsScreen extends StatefulWidget {
  final String languageId;
  final bool changer;
  const FontsScreen({Key? key, required this.languageId, required this.changer})
      : super(key: key);

  @override
  State<FontsScreen> createState() => _FontsScreenState();
}

class _FontsScreenState extends State<FontsScreen> {
  Future<void> createFont() async {
    try {
      final url = Uri.parse(
          'http://192.168.106.159:3000/api/fonts/create?languageID=${widget.languageId}');

      final response = await http.post(url);

      // Handle the response as needed
    } catch (error) {
      // Handle network or other errors
    }
  }

  Future<void> downloadFile(
      String fileUrl, String storageDirectory, String fileName) async {
    try {
      final response = await http.get(Uri.parse(fileUrl));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading'),
          ),
        );

        final downloadsDir = await getDownloadsDirectory();

        final directoryPath = '${downloadsDir?.path}/$storageDirectory';
        final filePath = '$directoryPath/$fileName.ttf';

        final directory = Directory(directoryPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final file = File(filePath);

        final contentLength = response.contentLength;
        final bytesReceived = <int>[];

        response.bodyBytes.forEach((byte) {
          bytesReceived.add(byte);
          final progress = (bytesReceived.length / contentLength!) * 100;
        });

        await file.writeAsBytes(bytesReceived);
        print('File downloaded successfully');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryColor,
            content: Text(
              'File Downloaded sucessfully.',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
          ),
        );

        print('File saved at: $filePath'); // Print the file location
      } else {
        // Handle HTTP errors
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the download process
      print('Error downloading file: $e');
    }
  }

  Future<void> showDownloadDialog(BuildContext context, String fileUrl) async {
    String storageDirectory = "";
    String fileName = "";

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Download File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  storageDirectory = value;
                },
                decoration: InputDecoration(labelText: 'Storage Directory'),
              ),
              TextField(
                onChanged: (value) {
                  fileName = value;
                },
                decoration: InputDecoration(labelText: 'File Name'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Download'),
              onPressed: () {
                Navigator.of(context).pop();
                downloadFile(fileUrl, storageDirectory, fileName);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fonts'),
      ),
      body: Column(
        children: [
          Container(
            height: 50.0,
            child: Container(
              height: 50.0,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Fonts",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  if (widget.changer == false)
                    ElevatedButton(
                      onPressed: createFont,
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      child: Text(
                        '+ CREATE',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                ],
              ),
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('languages')
                .doc(widget.languageId)
                .collection('fonts')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              final documents = snapshot.data!.docs;

              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document =
                        documents[index].data() as Map<String, dynamic>;

                    final fileUrl = document['file'] as String;

                    return ListTile(
                      title: Text("font"),
                      subtitle: Text("Click to download"),
                      onTap: () {
                        showDownloadDialog(context, fileUrl);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
