import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';

import 'package:frontend/screens/character.dart';

class LanguageDocumentScreen extends StatefulWidget {
  final String documentId;
  final bool changer;

  LanguageDocumentScreen({required this.documentId, required this.changer});

  @override
  _LanguageDocumentScreenState createState() => _LanguageDocumentScreenState();
}

class _LanguageDocumentScreenState extends State<LanguageDocumentScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Set the number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Text(
            'Language',
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Elements'),
              Tab(text: 'Issues'),
              Tab(text: 'Change Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Content for Tab 1
            ElementsTab(changer: widget.changer, documentId: widget.documentId),

            // Content for Tab 2
            IssuesTab(languageId: widget.documentId),

            // Content for Tab 3
            ChangeRequestTab(languageId: widget.documentId),
          ],
        ),
      ),
    );
  }
}

class ElementsTab extends StatefulWidget {
  final String documentId;
  final bool changer;

  ElementsTab({required this.documentId, required this.changer});

  @override
  _ElementsTabState createState() => _ElementsTabState();
}

class _ElementsTabState extends State<ElementsTab> {
  late Future<DocumentSnapshot> documentSnapshot;
  bool isCollaborator = false;

  @override
  void initState() {
    super.initState();
    documentSnapshot = getLanguageDocument(widget.documentId);
  }

  Future<DocumentSnapshot> getLanguageDocument(String documentId) async {
    final document = await FirebaseFirestore.instance
        .collection('languages')
        .doc(documentId)
        .get();
    return document;
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user!.uid.toString();

    Future<void> copyDocument(String sourceCollection, String documentId,
        String targetCollection) async {
      final firestore = FirebaseFirestore.instance;

      // Get the source document
      final sourceDocumentSnapshot =
          await firestore.collection(sourceCollection).doc(documentId).get();
      if (!sourceDocumentSnapshot.exists) {
        // Document not found in the source collection
        return;
      }

      // Create a copy of the document in the target collection
      await firestore
          .collection(targetCollection)
          .doc(documentId)
          .set(sourceDocumentSnapshot.data()!);

      // Now, add two fields to the copied document in the target collection
      final Map<String, dynamic> additionalData = {
        'languageID': widget.documentId,
        'changer': uid,
        'status': "none",
      };

      await firestore
          .collection(targetCollection)
          .doc(documentId)
          .update(additionalData);

// navigate to the new document in target collection
    }

    void addContributorToDocument() {
      final CollectionReference languagesCollection =
          FirebaseFirestore.instance.collection('languages');

      // Update the contributors array in the document
      languagesCollection.doc(widget.documentId).update({
        'collaborators': FieldValue.arrayUnion([uid]),
      });
      copyDocument("languages", widget.documentId, "changerequests");
    }

    return SingleChildScrollView(
      child: FutureBuilder<DocumentSnapshot>(
        future: documentSnapshot,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              // Access the document data here
              final languageData =
                  snapshot.data!.data() as Map<String, dynamic>;
              final List<dynamic> collaborators =
                  languageData['collaborators'] ?? [];

              // Check if the user's UID is in the collaborators list
              isCollaborator = collaborators.contains(uid);
              // Display the data on the screen as needed
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unchanging content
                    Text(
                      '${languageData['name']}',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${languageData['description']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Divider(),
                    Text(
                      'Region: ${languageData['region']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Ethnicity: ${languageData['ethnicity']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Family: ${languageData['family']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Speakers: ${languageData['speakers']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Endangerment: ${languageData['endangerment']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    if (languageData['maintainer'] == uid)
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                        ),
                        child: Text(
                          'Update Details',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    if (languageData['maintainer'] != uid && !isCollaborator)
                      ElevatedButton(
                        onPressed: addContributorToDocument,
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                        ),
                        child: Text(
                          '+ CHANGE REQUEST',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),

                    // add new here

                    // Content of character tabs
                    Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.folder,
                              color: AppColors.primaryColor,
                              size: 36.0,
                            ),
                            title: Text(
                              'Characters',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CharacterScreen(
                                    changer: widget.changer,
                                    languageId: widget.documentId,
                                  ),
                                ),
                              );
                            },
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(
                              Icons.folder,
                              color: AppColors.primaryColor,
                              size: 36.0,
                            ),
                            title: Text(
                              'Words & Literature',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            onTap: () {},
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(
                              Icons.folder,
                              color: AppColors.primaryColor,
                              size: 36.0,
                            ),
                            title: Text(
                              'Datasets',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            onTap: () {},
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(
                              Icons.folder,
                              color: AppColors.primaryColor,
                              size: 36.0,
                            ),
                            title: Text(
                              'Fonts',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    // Add more fields as needed
                  ],
                ),
              );
            } else {
              return Text('Language not found.');
            }
          }
        },
      ),
    );
  }
}

class ChangeRequestTab extends StatefulWidget {
  final String languageId;
  const ChangeRequestTab({super.key, required this.languageId});

  @override
  State<ChangeRequestTab> createState() => _ChangeRequestTabState();
}

class _ChangeRequestTabState extends State<ChangeRequestTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change Requests',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Add Language Button
              ],
            ),
            // Show all user Languages
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('languages')
                  .doc(widget.languageId)
                  .collection('changerequests')
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
                    final name = document['title'];
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
                        onTap: () {},
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class IssuesTab extends StatefulWidget {
  final String languageId;
  const IssuesTab({super.key, required this.languageId});

  @override
  State<IssuesTab> createState() => _IssuesTabState();
}

class _IssuesTabState extends State<IssuesTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Issues",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
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
            // Show all user Languages
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('languages')
                  .doc(widget.languageId)
                  .collection('issues')
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
                    final name = document['title'];
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
                        onTap: () {},
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
