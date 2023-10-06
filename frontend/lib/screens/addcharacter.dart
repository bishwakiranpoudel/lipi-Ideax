import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class Addcharacter extends StatefulWidget {
  final String documentId;

  Addcharacter({required this.documentId});

  @override
  _AddcharacterState createState() => _AddcharacterState();
}

class _AddcharacterState extends State<Addcharacter> {
  final GlobalKey<SfSignaturePadState> _signatureGlobalKey = GlobalKey();
  TextEditingController _unicodeController = TextEditingController();
  File? _image;
  File? _audio;
  bool _isRecording = false;

  Future<void> _submitForm() async {
    final uri = Uri.parse('http://192.168.106.159:3000/api/characters/upload');

    // Create a multipart request
    final request = http.MultipartRequest('POST', uri);

    // Add file fields
    request.files.add(
      http.MultipartFile(
        'image',
        _image!.readAsBytes().asStream(),
        _image!.lengthSync(),
        filename: 'image.jpg', // Adjust the filename as needed
        contentType:
            MediaType('image', 'jpeg'), // Adjust the content type as needed
      ),
    );
    request.files.add(
      http.MultipartFile(
        'audio',
        _audio!.readAsBytes().asStream(),
        _audio!.lengthSync(),
        filename: 'audio.mp3', // Adjust the filename as needed
        contentType:
            MediaType('audio', 'mpeg'), // Adjust the content type as needed
      ),
    );

    // Add other form fields
    request.fields['unicode'] = _unicodeController.text;
    request.fields['languageID'] = widget.documentId;

    // Send the request
    final response = await request.send();

    // Handle the response
    if (response.statusCode == 200) {
      print('File upload successful');

      // clear text field
      _unicodeController.clear();
      // clear image and audio
      _handleClearButtonPressed();

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
    } else {
      print('File upload failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[400],
          content: Text(
            'Failed to Add character',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Request necessary permissions when the widget initializes.
    _requestPermissions();
    _requestAudioPermission();
  }

  // Function to request permissions.
  Future<void> _requestPermissions() async {
    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      // Permission granted. You can proceed with saving the image.
      _requestAudioPermission();
    } else if (storageStatus.isDenied) {
      // Permission denied. Handle it gracefully, e.g., show an error message.
      _showPermissionErrorDialog('storage');
    } else if (storageStatus.isPermanentlyDenied) {
      // Permission permanently denied. You can ask the user to go to app settings to manually enable the permission.
      _showPermissionSettingsDialog('storage');
    }
  }

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

  void _handleClearButtonPressed() {
    _signatureGlobalKey.currentState!.clear();
    setState(() {
      _image = null; // Clear the existing image.
    });
  }

  Future<void> _handleSaveButtonPressed() async {
    try {
      final data =
          await _signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
      print(data);
      final bytes = await data.toByteData(format: ui.ImageByteFormat.png);

      final directory = await getApplicationDocumentsDirectory();
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_signature.png';
      final file = File('${directory.path}/$uniqueFileName');
      await file
          .writeAsBytes(Uint8List.sublistView(bytes!.buffer.asUint8List()));

      setState(() {
        _image = file;
      });
      _submitForm();
    } catch (e) {
      print('Error saving image: $e');
      // Handle the error gracefully, e.g., show an error message.
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Add Character',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              child: SfSignaturePad(
                minimumStrokeWidth: 15.0,
                maximumStrokeWidth: 15.0,
                key: _signatureGlobalKey,
                backgroundColor: Colors.transparent,
                strokeColor: Colors.black,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                image: DecorationImage(
                  image: AssetImage(
                      'assets/container.png'), // Replace with your image asset path
                  fit: BoxFit
                      .cover, // Adjust the fit as needed (cover, contain, etc.)
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: _handleClearButtonPressed,
              style: TextButton.styleFrom(
                primary: AppColors.primaryColor, // Set the text color to blue
              ),
              child: Text('Clear'),
            ),
            SizedBox(height: 16.0),
            AudioRecorderWidget(
              onStop: (path) {
                setState(() {
                  _audio = File(path);
                });
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _unicodeController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Unicode',
                hintText: 'Enter your unicode',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _handleSaveButtonPressed,
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 50.0,
                      vertical: 15.0,
                    ),
                  ),
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AudioRecorderWidget extends StatefulWidget {
  final void Function(String path) onStop;

  const AudioRecorderWidget({Key? key, required this.onStop}) : super(key: key);

  @override
  _AudioRecorderWidgetState createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;

  @override
  void initState() {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });

    super.initState();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();
        _recordDuration = 0;
        _startTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _recordDuration = 0;

    final path = await _audioRecorder.stop();

    if (path != null) {
      widget.onStop(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRecordStopControl(),
        if (_recordState == RecordState.record) _buildTimer(),
      ],
    );
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_recordState != RecordState.stop) {
      icon = const Icon(Icons.stop, color: AppColors.textColor, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      icon = Icon(Icons.mic, color: AppColors.textColor, size: 30);
      color = AppColors.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            (_recordState != RecordState.stop) ? _stop() : _start();
          },
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes:$seconds',
      style: TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }
}
