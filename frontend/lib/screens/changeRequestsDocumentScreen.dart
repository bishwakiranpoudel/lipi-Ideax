import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/updateChangeRequestDetail.dart';

class ChangeRequestDocumentScreen extends StatefulWidget {
  final String documentId;
  const ChangeRequestDocumentScreen({super.key, required this.documentId});

  @override
  State<ChangeRequestDocumentScreen> createState() =>
      _ChangeRequestDocumentScreenState();
}

class _ChangeRequestDocumentScreenState
    extends State<ChangeRequestDocumentScreen> {
  late Future<DocumentSnapshot> documentSnapshot;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController reviewController = TextEditingController();
  final TextEditingController discussionController = TextEditingController();
  late CollectionReference discussionCollection = FirebaseFirestore.instance
      .collection('changerequests')
      .doc(widget.documentId)
      .collection('discussion');
  @override
  void initState() {
    super.initState();
    documentSnapshot = getLanguageDocument(widget.documentId);
  }

  Future<DocumentSnapshot> getLanguageDocument(String documentId) async {
    final document = await FirebaseFirestore.instance
        .collection('changerequests')
        .doc(documentId)
        .get();
    return document;
  }

  Future<void> submitReview() async {
    final reviewText = reviewController.text;
    final currentDate = Timestamp.now();

    // Add the review to the discussion subcollection with the current date.
    await discussionCollection.add({
      'text': reviewText,
      'date': currentDate,
    });

    // Clear the review text field.
    reviewController.clear();
  }

  Future<void> _showInputDialog(
      BuildContext context, String changerId, String languageId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Request Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                // Add the title and description to the Firestore sub-collection
                final firestore = FirebaseFirestore.instance;
                final data = {
                  'changer': changerId,
                  'changerequest': widget.documentId,
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'status': "pending"
                  // Add any other fields you want to store
                };
                await firestore
                    .collection('languages')
                    .doc(languageId)
                    .collection('changerequests')
                    .add(data);
                // Create change request sub-collection in language of id languagedata['languageId']
                // Add changerid, changerequestId(widget.languageId), Date datetime.now
                // Change request status to "pending"
                await firestore
                    .collection("changerequests")
                    .doc(widget.documentId)
                    .update({"status": "pending"});
                setState(() {
                  documentSnapshot = getLanguageDocument(widget.documentId);
                });
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget buildDiscussion() {
    return StreamBuilder<QuerySnapshot>(
      stream: discussionCollection.orderBy('date').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No discussions yet.');
        }

        final discussionDocs = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              'Discussion',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: discussionDocs.map((doc) {
                final date = doc['date'] as Timestamp;
                final text = doc['text'] as String;

                final formattedDate = DateTime.fromMillisecondsSinceEpoch(
                  date.seconds * 1000,
                ).toLocal();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate.toString(),
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(text),
                    SizedBox(height: 8),
                  ],
                );
              }).toList(),
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
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Change Request',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
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
                      if (languageData['status'] == "none")
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UpdateChangeRequestDetials(
                                  languageId: widget.documentId,
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
                            'Update Details',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      if (languageData['status'] == "none")
                        ElevatedButton(
                          onPressed: () async {
                            _showInputDialog(context, languageData['changer'],
                                languageData['languageID']);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: AppColors.primaryColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                          ),
                          child: Text(
                            'Submit Change Request',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      if (languageData['status'] == "pending")
                        Container(
                          color: Colors.amber[700],
                          child: Text(
                            "Approval Pending",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      if (languageData['status'] == "merged")
                        Container(
                          color: Colors.green[300],
                          child: Text(
                            "Merged",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      if (languageData['status'] == "rejected")
                        Container(
                          color: Colors.red[300],
                          child: Text(
                            "rejected",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      SizedBox(height: 8),
                      TextField(
                        controller: reviewController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Write your review here...',
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: submitReview,
                        child: Text('Submit Review'),
                      ),
                      buildDiscussion(), // Add more fields as needed
                    ],
                  ),
                );
              } else {
                return Text('Language not found.');
              }
            }
          },
        ),
      ),
    );
  }
}
