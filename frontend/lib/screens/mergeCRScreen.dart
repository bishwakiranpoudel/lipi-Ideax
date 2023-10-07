import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';

class MergeRequestsScreen extends StatefulWidget {
  final String languageId;
  final String changeRequestId;

  const MergeRequestsScreen({
    super.key,
    required this.languageId,
    required this.changeRequestId,
  });

  @override
  State<MergeRequestsScreen> createState() => _MergeRequestsScreenState();
}

class _MergeRequestsScreenState extends State<MergeRequestsScreen> {
  late Future<DocumentSnapshot> changeRequestSnapshot;
  late Future<DocumentSnapshot> languageSnapshot;
  late TextEditingController reviewController;
  late CollectionReference discussionCollection;
  bool submitted = true;

  @override
  void initState() {
    super.initState();
    changeRequestSnapshot = getChangeRequestDocument(widget.changeRequestId);
    languageSnapshot = getLanguageDocument(widget.languageId);
    reviewController = TextEditingController();
    discussionCollection = FirebaseFirestore.instance
        .collection('changerequests')
        .doc(widget.changeRequestId)
        .collection('discussion');
  }

  Future<DocumentSnapshot> getLanguageDocument(String documentId) async {
    final document = await FirebaseFirestore.instance
        .collection('languages')
        .doc(documentId)
        .get();
    return document;
  }

  Future<DocumentSnapshot> getChangeRequestDocument(String documentId) async {
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

  void mergeFields(
      DocumentSnapshot changeRequestDoc, DocumentSnapshot languageDoc) async {
    // Merge fields from "changerequests" to "languages".
    final changeRequestData = changeRequestDoc.data() as Map<String, dynamic>?;
    final languageData = languageDoc.data() as Map<String, dynamic>?;

    if (changeRequestData != null && languageData != null) {
      final Map<String, dynamic> mergedData = {
        ...languageData,
        ...changeRequestData
      };

      // Update the fields in the "languages" collection.
      await FirebaseFirestore.instance
          .collection('languages')
          .doc(widget.languageId)
          .update(mergedData);

      await FirebaseFirestore.instance
          .collection('changerequests')
          .doc(widget.changeRequestId)
          .update({'status': 'merged'});
      setState(() {
        submitted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryColor,
          content: Text(
            'Character added successfully',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Widget buildFieldComparison({
    required String fieldName,
    required DocumentSnapshot changeRequestDoc,
    required DocumentSnapshot languageDoc,
  }) {
    final changeRequestField = (changeRequestDoc.data()
        as Map<String, dynamic>?)?[fieldName] as String?;
    final languageField =
        (languageDoc.data() as Map<String, dynamic>?)?[fieldName] as String?;

    // Compare the field and determine whether to highlight in red or not.
    final highlightRed = changeRequestField != languageField;

    return Row(
      children: [
        Text(
          fieldName + ':',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8),
        Text(
          changeRequestField!,
          style: TextStyle(
            color: highlightRed ? Colors.red : Colors.black,
          ),
        ),
      ],
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
        title: Text('Merge Request'),
        actions: [
          IconButton(
            onPressed: () async {
              final changeRequestDoc = await changeRequestSnapshot;
              final languageDoc = await languageSnapshot;
              mergeFields(changeRequestDoc, languageDoc);
            },
            icon: Icon(Icons.merge,
                color: Colors.white), // Replace with the icon you want to use.
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: FutureBuilder(
          future: Future.wait([changeRequestSnapshot, languageSnapshot]),
          builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || snapshot.data!.length != 2) {
              return Text('Data not available');
            }

            final changeRequestDoc = snapshot.data![0];
            final languageDoc = snapshot.data![1];
            if ((changeRequestDoc.data() as Map<String, dynamic>?)?['status'] ==
                "pending") {
              submitted = false;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(4)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'status: ${(changeRequestDoc.data() as Map<String, dynamic>?)?['status']}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'changer: ${(changeRequestDoc.data() as Map<String, dynamic>?)?['changer']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                buildFieldComparison(
                  fieldName: 'description',
                  changeRequestDoc: changeRequestDoc,
                  languageDoc: languageDoc,
                ),
                buildFieldComparison(
                  fieldName: 'endangerment',
                  changeRequestDoc: changeRequestDoc,
                  languageDoc: languageDoc,
                ),
                buildFieldComparison(
                  fieldName: 'ethnicity',
                  changeRequestDoc: changeRequestDoc,
                  languageDoc: languageDoc,
                ),
                buildFieldComparison(
                  fieldName: 'family',
                  changeRequestDoc: changeRequestDoc,
                  languageDoc: languageDoc,
                ),
                buildFieldComparison(
                  fieldName: 'speakers',
                  changeRequestDoc: changeRequestDoc,
                  languageDoc: languageDoc,
                ),
                SizedBox(height: 16),
                Text(
                  'Add Review',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
                buildDiscussion(),
              ],
            );
          },
        ),
      ),
    );
  }
}
