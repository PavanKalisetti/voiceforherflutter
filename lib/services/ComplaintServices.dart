import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voiceforher/utils/constants.dart';
import '../models/complaint_model.dart';


class ComplaintService {
  final String apiUrl = Constants.baseUrl;

  Future<void> raiseComplaint({
    required String token,
    required Complaint complaint,
  }) async {
    try {
      // Convert Complaint object to a JSON-compatible map
      final Map<String, dynamic> requestBody = complaint.toMap();

      // Send the POST request
      final response = await http.post(
        Uri.parse('$apiUrl/complaint/raiseComplaint'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");


      // Handle response
      if (response.statusCode == 201) {
        print("Complaint raised successfully: ${jsonDecode(response.body)}");
      } else {
        print("Failed to raise complaint: ${response.body}");
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (error) {
      print("An error occurred while raising the complaint: $error");
      throw Exception("Failed to raise complaint");
    }
  }

  Future<List<Complaint>> fetchComplaints(String token) async {


    final response = await http.get(
      Uri.parse('$apiUrl/complaint/fetchComplaint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("debug testing in status code 200");
      final List complaintsJson = jsonDecode(response.body)['complaints'];
      return complaintsJson.map((json) => Complaint.fromJson(json)).toList();
    } else {
      print("debug testing in else");
      throw Exception('Failed to load complaints');
    }
  }
}
