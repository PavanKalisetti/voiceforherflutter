import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:voiceforher/utils/constants.dart';

class FileUploadService {
  String baseurl = Constants.baseUrl;
  static final String baseUrl = "$baseUrl/files"; // Replace with your server URL

  static Future<void> uploadImage(BuildContext context, XFile? imageFile) async {
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected!')),
      );
      return;
    }

    try {
      var uri = Uri.parse('$baseUrl/upload');
      var request = http.MultipartRequest('POST', uri);

      // Add the image as a multipart request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // Add any other fields (like the userId) if necessary
      // request.fields['userId'] = 'user-id';  // Replace with actual user ID

      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image!')),
        );
      }
    } catch (error) {
      print('Error uploading image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image!')),
      );
    }
  }

  static Future<XFile?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera); // Use camera

    return pickedFile;
  }
}
