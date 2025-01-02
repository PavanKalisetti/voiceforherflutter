import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageRecognition extends StatefulWidget {
  const ImageRecognition({Key? key}) : super(key: key);

  @override
  State<ImageRecognition> createState() => _ImageRecognitionState();
}

class _ImageRecognitionState extends State<ImageRecognition> {
  File? _image;
  String _result = '';

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _recognizeImage() async {
    if (_image == null) {
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://61.1.174.144:5000/recognize'));
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        Map<String, dynamic> data = jsonDecode(responseString);

        setState(() {
          _result = data['matched_names'].join(', ');
        });
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
              onPressed: _getImage,
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