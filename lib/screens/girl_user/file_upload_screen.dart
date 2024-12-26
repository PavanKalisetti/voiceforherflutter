import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/file_upload_service.dart';
// import 'file_upload_service.dart'; // Import the file upload service

class FileUploadScreen extends StatefulWidget {
  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  XFile? _imageFile;

  // Function to pick an image from camera
  void _pickImage() async {
    XFile? pickedFile = await FileUploadService.pickImage();
    setState(() {
      _imageFile = pickedFile;
    });
  }

  // Function to upload the image
  void _uploadImage() {
    FileUploadService.uploadImage(context, _imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Image')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the picked image
            _imageFile != null
                ? Image.file(
              File(_imageFile!.path),
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            )
                : Text('No image selected.'),
            SizedBox(height: 20),
            // Button to open camera and pick image
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Open Camera'),
            ),
            SizedBox(height: 20),
            // Button to upload the image
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
