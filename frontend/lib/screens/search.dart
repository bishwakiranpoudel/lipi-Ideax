import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/language.dart';

class SearchScreen extends StatefulWidget {
  final String initialQueryString;

  SearchScreen({required this.initialQueryString});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late String queryString;

  @override
  void initState() {
    super.initState();
    queryString = widget.initialQueryString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: TextField(
          onChanged: (value) {
            setState(() {
              queryString = value;
            });
          },
          decoration: InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
          ),
          controller: TextEditingController(text: queryString),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('languages')
            .where('search', isGreaterThanOrEqualTo: queryString.toLowerCase())
            .where('search',
                isLessThanOrEqualTo: queryString.toLowerCase() + '\uf8ff')
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
              final name = document['name'];
              final description = document['description'];
              final documentId = document.id;

              return Card(
                margin: EdgeInsets.symmetric(
                  vertical: 8.0,
                ),
                elevation: 2.0, // Decreased shadow elevation
                child: ListTile(
                  title: Text(
                    name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LanguageDocumentScreen(
                          changer: true,
                          documentId: documentId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
