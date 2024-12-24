import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voiceforher/utils/constants.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = Constants.baseUrl;

  static Future<Map<String, dynamic>> registerUser(UserModel user) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body); // Success
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  static Future<User> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body)['message'];
      throw Exception(error);
    }
  }

  // Function to raise a complaint
  Future<void> raiseComplaint({
    required String token,
    required String subject,
    required String description,
    required String category,
    required String location,
    required DateTime dateOfIncident,
    bool isAnonymous = false,
  }) async {
    try {
      // Create the request body
      final Map<String, dynamic> requestBody = {
        "subject": subject,
        "description": description,
        "category": category,
        "location": location,
        "dateOfIncident": dateOfIncident.toIso8601String(),
        "isAnonymous": isAnonymous,
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse('$baseUrl/complaint/raiseComplaint'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      // Check the response status
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print("Complaint raised successfully: ${responseData['complaint']}");
      } else {
        print("Failed to raise complaint: ${response.body}");
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (error) {
      print("An error occurred while raising the complaint: $error");
      throw Exception("Failed to raise complaint");
    }
  }
}
