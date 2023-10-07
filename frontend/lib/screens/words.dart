import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/addWords.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class WordsScreen extends StatefulWidget {
  final String languageId;
  final bool changer;

  const WordsScreen(
      {super.key, required this.languageId, required this.changer});
  @override
  _WordsScreenState createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  late Future<DocumentSnapshot> documentSnapshot;
  TextStyle? _customFont;

  Future<void> loadAndApplyCustomFont(String fontUrl) async {
    final response = await http.get(Uri.parse(fontUrl));

    if (response.statusCode == 200) {
      final fontData = Uint8List.fromList(response.bodyBytes);

      // Load the custom font into Flutter as a font asset
      final fontLoader = FontLoader(widget.languageId)
        ..addFont(Future.value(ByteData.sublistView(fontData)));

      await fontLoader.load();

      // Create a TextStyle with the custom font
      final customFont = TextStyle(
        fontFamily: widget.languageId,
        fontSize: 16.0,
      );

      // Set the customFont to the _customFont variable
      setState(() {
        _customFont = customFont;
      });
    } else {
      // Handle error when downloading the font
      throw Exception('Failed to download font');
    }
  }

  Future<void> loadFontFromFirestore() async {
    final document = await FirebaseFirestore.instance
        .collection('languages')
        .doc(widget.languageId)
        .get();

    if (document.exists) {
      final fontUrl = document.data()?['font'] as String?;
      if (fontUrl != null) {
        await loadAndApplyCustomFont(fontUrl);
      }
    } else {
      // Handle error when the document doesn't exist
      throw Exception('Language document not found');
    }
  }

  @override
  void initState() {
    super.initState();
    // Load the font from Firestore when the screen first loads
    loadFontFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Words'),
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
                    "Words",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  if (widget.changer == false)
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddWordsScreen(
                                      languageId: widget.languageId,
                                    )));
                      },
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      child: Text(
                        '+ ADD',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _customFont != null
              ? StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('languages')
                      .doc(widget.languageId)
                      .collection('words')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final documents = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final document = documents[index];
                        final nativ = document['native'];
                        final description = document['meaning'];
                        final english = document['english'];
                        final documentId = document.id;

                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          elevation: 2.0, // Decreased shadow elevation
                          child: ListTile(
                            title: Text(
                              nativ,
                              style: _customFont,
                            ),
                            subtitle: Text(
                              description,
                              style: _customFont,
                            ),
                            onTap: () {},
                          ),
                        );
                      },
                    );
                  },
                )
              : CircularProgressIndicator(),
        ],
      ),
    );
  }
}
