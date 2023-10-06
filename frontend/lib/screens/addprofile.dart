import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProfileScreen extends StatefulWidget {
  const AddProfileScreen({
    Key? key,
  });

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  String dp = '';
  String url = '';
  UploadTask? task;

  File image = File('');
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  TextEditingController _nameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('profiles');

  Future<void> addUser() async {
    try {
      // Check if an image is selected
      if (image != null) {
        // Create a reference to the Firebase Storage location where you want to store the image
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_images/${DateTime.now()}.jpg');

        // Upload the image to Firebase Storage
        final UploadTask uploadTask = storageReference.putFile(image);

        // Get the download URL once the image is uploaded
        await uploadTask.whenComplete(() async {
          url = await storageReference.getDownloadURL();
        });
      }
      final User? usr = FirebaseAuth.instance.currentUser;
      final String uid = usr!.uid.toString();
      // Add user data to Firestore, including the image URL
      await users
          .add({
            'uid': uid,
            'name': _nameController.text.toString(),
            'bio': _bioController.text.toString(),
            'image': url, // Use the URL obtained from Firebase Storage
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.white,
                      child: image.path.isNotEmpty
                          ? ClipOval(
                              child: Image.file(
                                image,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 10,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: pickImage,
                        tooltip: 'Change Profile Picture',
                        child: Icon(
                          Icons.camera_alt,
                          color: Color(0xFF2E86C1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Enter your bio',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: addUser,
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 50.0,
                        vertical: 15.0,
                      ),
                    ),
                    child: Text('Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
