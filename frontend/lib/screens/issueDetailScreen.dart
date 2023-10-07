import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IssueDetailScreen extends StatefulWidget {
  final String languageId;
  final String issueId;
  const IssueDetailScreen(
      {super.key, required this.languageId, required this.issueId});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  late Future<DocumentSnapshot> documentSnapshot;
  final TextEditingController reviewController = TextEditingController();
  final TextEditingController discussionController = TextEditingController();
  late CollectionReference discussionCollection = FirebaseFirestore.instance
      .collection('languages')
      .doc(widget.languageId)
      .collection('issues')
      .doc(widget.issueId)
      .collection("discussion");

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
  void initState() {
    super.initState();
    documentSnapshot = getIssueDocument(widget.languageId, widget.issueId);
  }

  Future<DocumentSnapshot> getIssueDocument(
      String documentId, String issueId) async {
    final document = await FirebaseFirestore.instance
        .collection('languages')
        .doc(documentId)
        .collection("issues")
        .doc(issueId)
        .get();
    return document;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Issues"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<DocumentSnapshot>(
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
                            '${languageData['title']}',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${languageData['description']}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Divider(),
                          SizedBox(height: 8),
                          TextField(
                            controller: reviewController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Discuss here...',
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: submitReview,
                            child: Text('Submit'),
                          ),
                          buildDiscussion(),
                          // Add more fields as needed
                        ],
                      ),
                    );
                  } else {
                    return Text('issuenot found.');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
