import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceforher/utils/constants.dart';

class AllUserProfileScreen extends StatefulWidget {
  const AllUserProfileScreen({super.key});

  @override
  _AllUserProfileScreenState createState() => _AllUserProfileScreenState();
}

class _AllUserProfileScreenState extends State<AllUserProfileScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  final String apiUrl = Constants.baseUrl; // Replace with your API endpoint
  late final token;

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    try {
      final response = await http.get(Uri.parse('$apiUrl/profiles/allprofiles'), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body)['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> approveUser(String userId) async {

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/profiles/allprofiles/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User approved successfully')));
        fetchAllUsers(); // Refresh the list
      } else {
        throw Exception('Failed to approve user');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All User Profiles"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            child: ListTile(
              title: Text(user['username']),
              subtitle: Text(user['email']),
              trailing: user['isApproved']
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : ElevatedButton(
                onPressed: () => approveUser(user['_id']),
                child: const Text('Approve'),
              ),
            ),
          );
        },
      ),
    );
  }
}
