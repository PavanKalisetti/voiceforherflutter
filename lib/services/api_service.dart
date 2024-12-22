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
}
