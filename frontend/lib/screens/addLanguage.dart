import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/language.dart';

class AddLanguageScreen extends StatefulWidget {
  const AddLanguageScreen({super.key});

  @override
  State<AddLanguageScreen> createState() => _AddLanguageScreenState();
}

class _AddLanguageScreenState extends State<AddLanguageScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    // Set the initial value for the dropdown
    dropdownValue = endangeredList.first;
  }

  void clearFields() {
    // Clear all text field controllers
    _nameController.clear();
    _descriptionController.clear();
    _regionController.clear();
    _ethnicityController.clear();
    _familyController.clear();
    _nativeSpeakersController.clear();
    setState(() {
      dropdownValue = endangeredList.first;
    });
  }

  Future<void> addLanguage() async {
    final User? usr = FirebaseAuth.instance.currentUser;
    final String uid = usr!.uid.toString();
    CollectionReference languages =
        FirebaseFirestore.instance.collection('languages');
    try {
      DocumentReference documentRef = await languages.add({
        'name': _nameController.text.toString(),
        'description': _descriptionController.text.toString(),
        'region': _regionController.text.toString(),
        'ethnicity': _ethnicityController.text.toString(),
        'family': _familyController.text.toString(),
        'speakers': _nativeSpeakersController.text.toString(),
        'endangerment': dropdownValue.toString(),
        'maintainer': uid,
        'font': '',
        'search': _nameController.text.toString().toLowerCase()
      });

      String documentId = documentRef.id;
      print("Language Added with ID: $documentId");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LanguageDocumentScreen(
                  documentId: documentId,
                  changer: false,
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
          "Add Language",
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
                  labelText: 'Name',
                  hintText: 'Enter the Name of the language',
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
                  hintText: 'Enter the description of the language',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
                cursorColor: AppColors.textColor,
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _regionController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Region',
                  hintText: 'Enter Region the Language Belongs',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
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
                    borderSide: BorderSide(color: AppColors.primaryColor),
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
                    borderSide: BorderSide(color: AppColors.primaryColor),
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
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
                cursorColor: AppColors.textColor,
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: dropdownValue,
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                items: endangeredList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Endangerment',
                  prefixIcon: Icon(Icons.warning),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
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
                      'Add Language',
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
