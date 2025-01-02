import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:voiceforher/utils/constants.dart';

class ImageRecognition extends StatefulWidget {
  const ImageRecognition({Key? key}) : super(key: key);

  @override
  State<ImageRecognition> createState() => _ImageRecognitionState();
}

class _ImageRecognitionState extends State<ImageRecognition> {
  File? _image;
  String _result = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _recognizeImage() async {
    if (_image == null) {
      return;
    }

    try {
      String baseurl = Constants.baseUrl;
      var request = http.MultipartRequest('POST', Uri.parse('https://voiceforher-backend.vercel.app/recognize-face'));
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        print(responseString);
        Map<String, dynamic> data = jsonDecode(responseString);
        print(data);

        // Check if there are matched faces
        if (data['matchedFaces'] != null && data['matchedFaces'].isNotEmpty) {
          // Extract the matched face details
          var matchedFace = data['matchedFaces'][0];
          String name = matchedFace['NAME'];
          String branch = matchedFace['BRANCH'];
          String email = matchedFace['EMAIL_ADDRESS'];
          String phone = matchedFace['PHONE_NUMBER'];
          String year = matchedFace['YEAR'];

          // Update the result with the extracted details
          setState(() {
            _result = 'Name: $name\nBranch: $branch\nEmail: $email\nPhone: $phone\nYear: $year';
          });
        } else {
          setState(() {
            _result = 'No matched faces found.';
          });
        }
      } else {
        setState(() {
          _result = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
                width: 200,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showImageSourceDialog,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _recognizeImage,
              child: const Text('Recognize'),
            ),
            const SizedBox(height: 20),
            Text(
              'Result: $_result',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
