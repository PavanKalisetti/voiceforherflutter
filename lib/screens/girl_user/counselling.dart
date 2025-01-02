import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
          counsellingData =
              List<Map<String, dynamic>>.from(jsonResponse['data']);
          isLoading = false;
        });
      } else {
        showMessageDialog("Failed to fetch counselling data.");
      }
    } catch (error) {
      showMessageDialog("Error occurred: $error");
    }
  }

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
        fetchCounsellingData();
      } else {
        showMessageDialog("Failed to create counselling request.");
      }
    } catch (error) {
      showMessageDialog("Error occurred: $error");
    }
  }

  void showMessageDialog(String message) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          flexibleSpace: ClipPath(
            clipper: CurvedAppBarClipper(),
            child: Container(
              color: Colors.deepPurpleAccent,
            ),
          ),
          title: const Text(
            'Counselling Requests',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(
                child: SpinKitFadingCircle(
                  color: Colors.deepPurpleAccent,
                  size: 50.0,
                ),
              )
            : counsellingData.isEmpty
                ? const Center(
                    child: Text(
                      "No counselling data found.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: counsellingData.length,
                    itemBuilder: (context, index) {
                      final data = counsellingData[index];
                      final statusColor = data['status'] == 'pending'
                          ? Colors.orange
                          : data['status'] == 'completed'
                              ? Colors.blue
                              : data['status'] == 'rejected'
                                  ? Colors.red
                                  : Colors.green;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: ListTile(
                          onTap: () {
                            // Added functionality to show a dialog box based on status
                            String message;
                            switch (data['status']) {
                              case 'pending':
                                message =
                                    "Status: Pending\n\nWait for the allotment details.\nThe authority will review your request shortly.";
                                break;
                              case 'in-progress':
                                // final sessionDetails = data['sessionDetails'];
                                final date = data['scheduledDate'] ?? 'N/A';
                                final time = data?['scheduledTime'] ?? 'N/A';
                                final place = data['scheduledPlace'] ?? 'N/A';
                                message =
                                    "Status: In Progress\n\nSession Details:\nDate: $date \n Time: $time \nPlace: $place";
                                break;
                              case 'rejected':
                                final reason = data['authorityReason'] ??
                                    "No reason provided.";
                                message =
                                    "Status: Rejected\n\nYour request was rejected.\n\nReason: $reason";
                                break;
                              default:
                                message = "Status: Unknown\nUnknown status.";
                                break;
                            }

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Counselling Status"),
                                content: Text(message),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          },
                          leading: const CircleAvatar(
                            backgroundColor: Colors.deepPurpleAccent,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            data['reason'] ?? "No reason provided",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Status: ${data['status']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          trailing: Text(
                            data['createdAt']?.split('T')[0] ?? "N/A",
                            style: const TextStyle(
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
              title: const Text("Request Counselling"),
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
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
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
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
        label: const Text("Request Counselling"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
