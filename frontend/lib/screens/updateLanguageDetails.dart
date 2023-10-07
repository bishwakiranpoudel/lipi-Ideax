import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';

class UpdateLanguageDetials extends StatefulWidget {
  final String languageId;

  const UpdateLanguageDetials({
    super.key,
    required this.languageId,
  });

  @override
  State<UpdateLanguageDetials> createState() => _UpdateLanguageDetialsState();
}

class _UpdateLanguageDetialsState extends State<UpdateLanguageDetials> {
  TextEditingController _regionController = TextEditingController();
  TextEditingController _ethnicityController = TextEditingController();
  TextEditingController _familyController = TextEditingController();
  TextEditingController _nativeSpeakersController = TextEditingController();
  List<String> endangeredList = [
    'Safe',
    'Vulnerable',
    'Definitely Endangered',
    'Severely Endangered',
    'Critically Endangered',
    'Extinct'
  ];
  String dropdownValue = '';
  late Future<DocumentSnapshot> documentSnapshot;
  @override
  void initState() {
    super.initState();
    // Set the initial value for the dropdown
    dropdownValue = endangeredList.first;
    documentSnapshot = getLanguageDocument(widget.languageId);
  }

  Future<DocumentSnapshot> getLanguageDocument(String documentId) async {
    final document = await FirebaseFirestore.instance
        .collection('languages')
        .doc(documentId)
        .get();
    return document;
  }

  void clearFields() {
    // Clear all text field controllers
    _regionController.clear();
    _ethnicityController.clear();
    _familyController.clear();
    _nativeSpeakersController.clear();
    setState(() {
      dropdownValue = endangeredList.first;
    });
  }

  Future<void> updateLanguage() async {
    final firestore = FirebaseFirestore.instance;
    final User? usr = FirebaseAuth.instance.currentUser;
    final String uid = usr!.uid.toString();

    try {
      await firestore.collection("languages").doc(widget.languageId).update({
        'region': _regionController.text.toString(),
        'ethnicity': _ethnicityController.text.toString(),
        'family': _familyController.text.toString(),
        'speakers': _nativeSpeakersController.text.toString(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryColor,
          content: Text(
            'Update Sucessful',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error adding Language: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[300],
          content: Text(
            'Update Failed',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Text(
            "Add Language",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: documentSnapshot,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else {
              if (snapshot.hasData && snapshot.data != null) {
                final languageData =
                    snapshot.data!.data() as Map<String, dynamic>;
                _regionController.text = languageData['region'];
                _ethnicityController.text = languageData['ethnicity'];
                _familyController.text = languageData['family'];
                _nativeSpeakersController.text = languageData['speakers'];
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(height: 30.0),
                        TextFormField(
                          controller: _regionController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Region',
                            hintText: 'Enter Region the Language Belongs',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.primaryColor),
                            ),
                          ),
                          cursorColor: AppColors.textColor,
                        ),
                        SizedBox(height: 10.0),
                        TextFormField(
                          controller: _ethnicityController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Ethnicity',
                            hintText: 'Enter ethnicity the Language Belongs',
                            prefixIcon: Icon(Icons.people),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.primaryColor),
                            ),
                          ),
                          cursorColor: AppColors.textColor,
                        ),
                        SizedBox(height: 10.0),
                        TextFormField(
                          controller: _familyController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Family',
                            hintText: 'Enter the family the language belongs',
                            prefixIcon: Icon(Icons.family_restroom),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.primaryColor),
                            ),
                          ),
                          cursorColor: AppColors.textColor,
                        ),
                        SizedBox(height: 10.0),
                        TextFormField(
                          controller: _nativeSpeakersController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Native Speakers',
                            hintText: 'Enter the Number of Native Speakers',
                            prefixIcon: Icon(Icons.group),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.primaryColor),
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
                                primary:
                                    Colors.grey, // Change the color as needed
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
                              onPressed: updateLanguage,
                              style: ElevatedButton.styleFrom(
                                primary: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 50.0,
                                  vertical: 15.0,
                                ),
                              ),
                              child: Text(
                                'Update',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Text("Language not Found");
              }
            }
          },
        ));
  }
}
