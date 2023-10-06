import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/addcharacter.dart';
import 'package:frontend/screens/customKeyboard.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:record/record.dart';

import 'package:permission_handler/permission_handler.dart';

class AddWordsScreen extends StatefulWidget {
  final String languageId;

  const AddWordsScreen({super.key, required this.languageId});
  @override
  _AddWordsScreenState createState() => _AddWordsScreenState();
}

class _AddWordsScreenState extends State<AddWordsScreen> {
  TextEditingController nativeController = TextEditingController();
  TextEditingController meaningController = TextEditingController();
  TextEditingController englishTranslationController = TextEditingController();

  File? _audio;
  bool _isRecording = false;

  bool _readNative = true;
  bool _readmeaning = true;

  late Future<DocumentSnapshot> documentSnapshot;
  TextStyle? _customFont;

  void _insertnativeText(dynamic tex) {
    final String myText = tex.toString();
    final text = nativeController.text;
    final textSelection = nativeController.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    nativeController.text = newText;
    nativeController.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
  }

  void _insertmeaningText(dynamic tex) {
    final String myText = tex.toString();
    final text = meaningController.text;
    final textSelection = meaningController.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    meaningController.text = newText;
    meaningController.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
  }

  void _backspacenative() {
    final text = nativeController.text;
    final textSelection = nativeController.selection;
    final selectionLength = textSelection.end - textSelection.start;
    // There is a selection.
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      nativeController.text = newText;
      nativeController.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }
    // The cursor is at the beginning.
    if (textSelection.start == 0) {
      return;
    }
    // Delete the previous character
    final previousCodeUnit = text.codeUnitAt(textSelection.start - 1);
    final offset = _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
    final newStart = textSelection.start - offset;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    nativeController.text = newText;
    nativeController.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }

  void _backspacemeaning() {
    final text = meaningController.text;
    final textSelection = meaningController.selection;
    final selectionLength = textSelection.end - textSelection.start;
    // There is a selection.
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      meaningController.text = newText;
      meaningController.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }
    // The cursor is at the beginning.
    if (textSelection.start == 0) {
      return;
    }
    // Delete the previous character
    final previousCodeUnit = text.codeUnitAt(textSelection.start - 1);
    final offset = _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
    final newStart = textSelection.start - offset;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    meaningController.text = newText;
    meaningController.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }

  bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }

  Future<void> loadAndApplyCustomFont(String fontUrl) async {
    final response = await http.get(Uri.parse(fontUrl));

    if (response.statusCode == 200) {
      final fontData = Uint8List.fromList(response.bodyBytes);

      // Load the custom font into Flutter as a font asset
      final fontLoader = FontLoader(widget.languageId)
        ..addFont(Future.value(ByteData.sublistView(fontData)));

      await fontLoader.load();

      // Create a TextStyle with the custom font
      final customFont = TextStyle(
        fontFamily: widget.languageId,
        fontSize: 20.0,
      );

      // Set the customFont to the _customFont variable
      setState(() {
        _customFont = customFont;
      });
    } else {
      // Handle error when downloading the font
      throw Exception('Failed to download font');
    }
  }

  Future<void> loadFontFromFirestore() async {
    final document = await FirebaseFirestore.instance
        .collection('languages')
        .doc(widget.languageId)
        .get();

    if (document.exists) {
      final fontUrl = document.data()?['font'] as String?;
      if (fontUrl != null) {
        await loadAndApplyCustomFont(fontUrl);
      }
    } else {
      // Handle error when the document doesn't exist
      throw Exception('Language document not found');
    }
  }

  // Audio recording and saving Logic.
  // Function to request audio recording permissions.
  Future<void> _requestAudioPermission() async {
    final audioStatus = await Permission.microphone.request();
    if (audioStatus.isGranted) {
      // Audio recording permission granted. You can proceed with recording.
    } else if (audioStatus.isDenied) {
      // Permission denied. Handle it gracefully, e.g., show an error message.
      _showPermissionErrorDialog('microphone');
    } else if (audioStatus.isPermanentlyDenied) {
      // Permission permanently denied. You can ask the user to go to app settings to manually enable the permission.
      _showPermissionSettingsDialog('microphone');
    }
  }

  void _showPermissionErrorDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Permission Error'),
        content: Text(
            'Please grant $permissionName permission to use this feature.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showPermissionSettingsDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Permission Error'),
        content:
            Text('Please enable $permissionName permission in app settings.'),
        actions: [
          TextButton(
            child: Text('Open Settings'),
            onPressed: () {
              openAppSettings(); // Opens the app settings on the device.
            },
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _startRecordingAudio() async {
    try {
      if (await Record().hasPermission()) {
        await Record().start();
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      print('Error starting audio recording: $e');
    }
  }

  Future<void> _stopRecordingAudio() async {
    try {
      final path = await Record().stop();
      setState(() {
        _isRecording = false;
      });
      if (path != null) {
        setState(() {
          _audio = File(path);
        });
      }
    } catch (e) {
      print('Error stopping audio recording: $e');
    }
  }

  // Upload audio to firebase storage get download link and add all the data in cloud firestore.
  Future<void> _saveToFirebase() async {
    if (_audio == null) {
      // Handle case where no audio is recorded
      return;
    }

    // Step 1: Upload audio file to Firebase Storage
    final storage = FirebaseStorage.instance;
    final audioReference =
        storage.ref().child('audio/${nativeController.text}.m4a');

    try {
      await audioReference.putFile(_audio!);
    } catch (e) {
      // Handle any errors that occur during the upload
      print('Error uploading audio: $e');
      return;
    }

    // Step 2: Get the download URL for the uploaded audio file
    final audioDownloadURL = await audioReference.getDownloadURL();

    // Step 3: Create a map containing the data you want to add to Firestore
    final wordData = {
      'native': nativeController.text,
      'meaning': meaningController.text,
      'english': englishTranslationController.text,
      'audio': audioDownloadURL,
      // Add any other fields you want to store
    };

    // Step 4: Add the data to Cloud Firestore
    final firestore = FirebaseFirestore.instance;
    final languageId = widget.languageId;

    try {
      await firestore
          .collection('languages')
          .doc(languageId)
          .collection('words')
          .add(wordData);

      // Clear the text fields and audio file
      setState(() {
        nativeController.clear();
        meaningController.clear();
        englishTranslationController.clear();
        _audio = null;
      });

      // Show a success message or navigate to a different screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryColor,
          content: Text(
            'Word added sucessfully',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Handle any errors that occur during Firestore write
      print('Error adding word to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[300],
          content: Text(
            'Word Add failed',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Load the font from Firestore when the screen first loads
    loadFontFromFirestore();
    _requestAudioPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Words & Literature'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: _customFont != null
              ? Column(
                  children: <Widget>[
                    Text(
                      'Native:',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      onTap: () {
                        setState(() {});
                        _readmeaning = true;
                        _readNative = !_readNative;
                        // Show custom keyboard when the text field is tapped
                      },
                      showCursor: true,
                      readOnly: true,
                      style: _customFont,
                      controller: nativeController,
                      maxLines: null, // Allows multiple lines
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (!_readNative)
                      CustomKeyboard(
                          customFont: _customFont,
                          onTextInput: _insertnativeText,
                          onBackspace: _backspacenative),
                    SizedBox(height: 16.0),
                    Text('Meaning:',
                        style: TextStyle(
                            fontSize: 18.0)), // Improved styling and spacing
                    SizedBox(height: 8.0),
                    TextField(
                      onTap: () {
                        setState(() {
                          _readNative = true;
                          _readmeaning = !_readmeaning;
                        });
                      },
                      showCursor: true,
                      readOnly: true,
                      style: _customFont,
                      controller: meaningController,
                      maxLines: null, // Allows multiple lines
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (!_readmeaning)
                      CustomKeyboard(
                          customFont: _customFont,
                          onTextInput: _insertmeaningText,
                          onBackspace: _backspacemeaning),
                    SizedBox(height: 16.0),
                    Text('English Translation:',
                        style: TextStyle(
                            fontSize: 18.0)), // Improved styling and spacing
                    SizedBox(height: 8.0),
                    TextField(
                      onTap: () {
                        setState(() {});
                        _readmeaning = true;
                        _readNative = true;
                        // Show custom keyboard when the text field is tapped
                      },
                      controller: englishTranslationController,
                      maxLines: null, // Allows multiple lines
                      decoration: InputDecoration(
                        hintText: 'Enter English translation...',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    // Audio Recording
                    SizedBox(height: 20),
                    AudioRecorderWidget(
                      onStop: (path) {
                        print(path);
                        setState(() {
                          _audio = File(path);
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    // Save Button
                    ElevatedButton(
                      onPressed: _saveToFirebase,
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 50.0,
                          vertical: 15.0,
                        ),
                      ),
                      child: Text('Save', style: TextStyle(fontSize: 18.0)),
                    ),
                  ],
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
