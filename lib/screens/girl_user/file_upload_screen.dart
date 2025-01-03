
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:voiceforher/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';



class FileUploadScreen extends StatefulWidget {
  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  File? _videoFile;
  File? _audioFile;

  Future<void> getFile({
    required String id,
    required String type,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String baseurl = Constants.baseUrl;
    final url = "$baseurl/files/$id/$type";
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      // Save or display the file using `bytes`
      print('File retrieved successfully!');
    } else {
      print('Error retrieving file: ${response.body}');
    }
  }


  Future<void> uploadFile({
    required String name,
    File? image,
    File? video,
    File? audio,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String baseurl = Constants.baseUrl;
    final uri = Uri.parse("$baseurl/files/upload");
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name;

    // Helper function to determine MIME type
    MediaType? getMimeType(String filePath) {
      final extension = filePath.split('.').last.toLowerCase();
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          return MediaType('image', 'jpeg');
        case 'png':
          return MediaType('image', 'png');
        case 'gif':
          return MediaType('image', 'gif');
        case 'mp4':
          return MediaType('video', 'mp4');
        case 'mov':
          return MediaType('video', 'quicktime');
        case 'avi':
          return MediaType('video', 'x-msvideo');
        case 'mp3':
          return MediaType('audio', 'mpeg');
        case 'wav':
          return MediaType('audio', 'wav');
        default:
          return null; // Fallback to null for unknown types
      }
    }

    // Add image file with detected MIME type
    if (image != null) {
      final mimeType = getMimeType(image.path);
      if (mimeType != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: mimeType,
        ));
      }
    }

    // Add video file with detected MIME type
    if (video != null) {
      final mimeType = getMimeType(video.path);
      if (mimeType != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'video',
          video.path,
          contentType: mimeType,
        ));
      }
    }

    // Add audio file with detected MIME type
    if (audio != null) {
      final mimeType = getMimeType(audio.path);
      if (mimeType != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'audio',
          audio.path,
          contentType: mimeType,
        ));
      }
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      print('Files uploaded successfully!');
    } else {
      print('File upload failed: ${response.reasonPhrase}');
    }
  }



  Future<void> _pickFile(String type) async {
    XFile? pickedFile;
    File? file;

    if (type == 'image') {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    } else if (type == 'video') {
      pickedFile = await _picker.pickVideo(source: ImageSource.camera);
    } else if (type == 'audio') {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        file = File(result.files.single.path!);
      }
    }

    if (pickedFile != null) {
      setState(() {
        if (type == 'image') {
          _imageFile = File(pickedFile!.path);
        } else if (type == 'video') {
          _videoFile = File(pickedFile!.path);
        }
      });
    } else if (file != null) {
      setState(() {
        if (type == 'audio') {
          _audioFile = file;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('File Upload')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _pickFile('image'),
            child: Text('Pick Image'),
          ),
          ElevatedButton(
            onPressed: () => _pickFile('video'),
            child: Text('Pick Video'),
          ),
          ElevatedButton(
            onPressed: () => _pickFile('audio'),
            child: Text('Pick Audio'),
          ),
          ElevatedButton(
            onPressed: () async {
              await uploadFile(
                name: 'image',
                image: _imageFile,
                video: _videoFile,
                audio: _audioFile,
              );
            },
            child: Text('Upload Files'),
          ),
        ],
      ),
    );
  }
}
