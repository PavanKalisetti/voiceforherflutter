import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voiceforher/models/UserProfileModel.dart';
import 'package:voiceforher/utils/constants.dart';

class UserService {
  static const String baseUrl = Constants.baseUrl; // Replace with your API URL

  static Future<UserProfileModel> fetchUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profiles/getprofile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return UserProfileModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }
}
