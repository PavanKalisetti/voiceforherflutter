import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voiceforher/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounsellingPage extends StatefulWidget {
  const CounsellingPage({super.key});

  @override
  _CounsellingPageState createState() => _CounsellingPageState();
}

class _CounsellingPageState extends State<CounsellingPage> {
  List<Map<String, dynamic>> counsellingData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCounsellingData();
  }

  // Function to fetch counselling data
  Future<void> fetchCounsellingData() async {
    String baseurl = Constants.baseUrl;
    String url = "$baseurl/counselling/counselling";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          counsellingData = List<Map<String, dynamic>>.from(jsonResponse['data']);
          isLoading = false;
        });
      } else {
        showMessageDialog("Failed to fetch counselling data.");
      }
    } catch (error) {
      showMessageDialog("Error occurred: $error");
    }
  }

  // Function to create a new counselling request
  Future<void> createCounsellingRequest(String reason) async {
    String baseurl = Constants.baseUrl;
    String url = "$baseurl/counselling/counselling";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({"reason": reason}),
      );

      if (response.statusCode == 201) {
        showMessageDialog("Counselling request created successfully.");
        fetchCounsellingData(); // Refresh the data
      } else {
        showMessageDialog("Failed to create counselling request.");
      }
    } catch (error) {
      showMessageDialog("Error occurred: $error");
    }
  }

  // Show a dialog with a message
  void showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Counselling Requests"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : counsellingData.isEmpty
            ? Center(
          child: Text(
            "No counselling data found.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: counsellingData.length,
          itemBuilder: (context, index) {
            final data = counsellingData[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  data['reason'] ?? "No reason provided",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text("Status: ${data['status']}"),
                trailing: Text(
                  data['createdAt']?.split('T')[0] ?? "N/A",
                  style: TextStyle(
                      color: Colors.grey, fontSize: 12),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final reasonController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text("Request Counselling"),
              content: TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: "Enter the reason",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    if (reason.isNotEmpty) {
                      Navigator.of(context).pop();
                      createCounsellingRequest(reason);
                    } else {
                      showMessageDialog("Reason cannot be empty.");
                    }
                  },
                  child: Text("Submit",style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          );
        },
        label: Text("Request Counselling"),
        icon: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }
}
