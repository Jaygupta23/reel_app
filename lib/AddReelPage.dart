import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:reel_view/main.dart';

class AddReelPage extends StatefulWidget {
  @override
  _AddReelPageState createState() => _AddReelPageState();
}

class _AddReelPageState extends State<AddReelPage> {
  String? _fileName;
  PlatformFile? _pickedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
          _pickedFile = result.files.single;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'File picking canceled',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
          ),
          duration: Duration(seconds: 2), // Duration the SnackBar is visible
          backgroundColor: Colors.blueGrey, // Background color
          behavior: SnackBarBehavior.floating, // Floating SnackBar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Error picking file: $e',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
        ),
        duration: Duration(seconds: 2), // Duration the SnackBar is visible
        backgroundColor: Colors.blueGrey, // Background color
        behavior: SnackBarBehavior.floating, // Floating SnackBar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ));
    }
  }

  Future<void> _uploadFile() async {
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Pick Video File First!!',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
          ),
          duration: Duration(seconds: 2), // Duration the SnackBar is visible
          backgroundColor: Colors.blueGrey, // Background color
          behavior: SnackBarBehavior.floating, // Floating SnackBar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          )));
      return;
    }
    ;

    setState(() {
      _isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://192.168.0.113:8000/videos/upload/'), // Update with your API endpoint
      );
      request.files.add(
        http.MultipartFile(
          'videos12345',
          File(_pickedFile!.path!).readAsBytes().asStream(),
          File(_pickedFile!.path!).lengthSync(),
          filename: _pickedFile!.name,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Upload successful',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
            ),
            duration: Duration(seconds: 2), // Duration the SnackBar is visible
            backgroundColor: Colors.blueGrey, // Background color
            behavior: SnackBarBehavior.floating, // Floating SnackBar
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Upload failed: ${response.statusCode}',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
          ),
          duration: Duration(seconds: 2), // Duration the SnackBar is visible
          backgroundColor: Colors.blueGrey, // Background color
          behavior: SnackBarBehavior.floating, // Floating SnackBar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Error uploading file: $e',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
          ),
          duration: Duration(seconds: 2), // Duration the SnackBar is visible
          backgroundColor: Colors.blueGrey, // Background color
          behavior: SnackBarBehavior.floating, // Floating SnackBar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          )));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Reels",
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.video_file),
                        iconSize: 100,
                        color: Colors.blueGrey,
                        onPressed: _pickFile,
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isUploading ? null : _uploadFile,
                        child: _isUploading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text("Add Reel",
                                style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 60.0),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                if (_fileName != null)
                  Text(
                    "Selected File: $_fileName",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.squarePlus),
                  iconSize: 40,
                  color: Colors.white,
                  onPressed:
                      _pickFile, // Allow picking file by clicking this icon too
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.circlePlay),
                  iconSize: 40,
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  },
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.user),
                  iconSize: 40,
                  color: Colors.blue.shade100,
                  onPressed: () {
                    // Handle delete action if needed
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
