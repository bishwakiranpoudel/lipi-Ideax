import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/addcharacter.dart';

class CharacterScreen extends StatefulWidget {
  final String languageId;
  final bool changer;

  const CharacterScreen(
      {super.key, required this.languageId, required this.changer});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('Characters'),
      ),
      body: Column(
        children: [
          Container(
            height: 50.0,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Characters",
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
                          builder: (context) => Addcharacter(
                            documentId: widget.languageId,
                          ),
                        ),
                      );
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
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('languages')
                .doc(widget.languageId)
                .collection('characters')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final documents = snapshot.data!.docs;

              return Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns in the grid
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Card(
                        color: Colors.white,
                        elevation: 2.0,
                        margin: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white,
                              ),
                              width: 60,
                              height: 60,
                              child: SvgPicture.network(
                                document['image'],
                                placeholderBuilder: (BuildContext context) =>
                                    CircularProgressIndicator(),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(4)),
                              height: 53,
                              child: Row(
                                children: [
                                  SizedBox(width: 8.0),
                                  Text(
                                    "Unicode:",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 4.0),
                                  Text(
                                    document['unicode'],
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
