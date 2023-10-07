import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/issueDetailScreen.dart';
import 'package:frontend/screens/language.dart';

class AddIssueScreen extends StatefulWidget {
  final String languageId;
  const AddIssueScreen({super.key, required this.languageId});

  @override
  State<AddIssueScreen> createState() => _AddIssueScreenState();
}

class _AddIssueScreenState extends State<AddIssueScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the initial value for the dropdown
  }

  void clearFields() {
    // Clear all text field controllers
    _nameController.clear();
    _descriptionController.clear();
  }

  Future<void> addLanguage() async {
    final User? usr = FirebaseAuth.instance.currentUser;
    final String uid = usr!.uid.toString();
    CollectionReference languages = FirebaseFirestore.instance
        .collection('languages')
        .doc(widget.languageId)
        .collection("issues");
    try {
      DocumentReference documentRef = await languages.add({
        'title': _nameController.text.toString(),
        'description': _descriptionController.text.toString(),
      });

      String documentId = documentRef.id;
      print("Language Added with ID: $documentId");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => IssueDetailScreen(
                  issueId: documentId,
                  languageId: widget.languageId,
                )),
      );
    } catch (e) {
      print('Error adding Language: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "Add Issue",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 20.0),
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter the title of issue',
                  prefixIcon: Icon(Icons.language),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
                cursorColor: AppColors.textColor,
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter the description of the Issue',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
                cursorColor: AppColors.textColor,
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: clearFields,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey, // Change the color as needed
                      padding: EdgeInsets.symmetric(
                        horizontal: 50.0,
                        vertical: 15.0,
                      ),
                    ),
                    child: Text(
                      'Clear',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: addLanguage,
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 50.0,
                        vertical: 15.0,
                      ),
                    ),
                    child: Text(
                      'Add Issue',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
