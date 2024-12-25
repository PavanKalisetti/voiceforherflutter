import 'package:flutter/material.dart';
import 'package:voiceforher/screens/girl_user/raiseComplaint.dart';
import '../../models/complaint_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ComplaintServices.dart';

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({Key? key}) : super(key: key);

  @override
  _ComplaintListScreenState createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  late Future<List<Complaint>> _complaintsFuture;
  bool isGirlUser = false;

  @override
  void initState() {
    super.initState();
    _checkUserType();
    _complaintsFuture = _fetchComplaints();
  }

  Future<void> _checkUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isGirlUser = prefs.getBool('isGirlUser') ?? false;
    });
  }

  Future<List<Complaint>> _fetchComplaints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception("User token not found.");
      }
      return await ComplaintService().fetchComplaints(token);
    } catch (e) {
      throw Exception("Failed to load complaints: $e");
    }
  }

  void _showComplaintDetails(Complaint complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(complaint.subject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${complaint.category}"),
            Text("Location: ${complaint.location}"),
            Text("Date: ${complaint.dateOfIncident.toLocal().toString().split(' ')[0]}"),
            Text("Description: ${complaint.description}"),
            if (complaint.isAnonymous)
              const Text(
                "Raised anonymously",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Handle chat action
            },
            child: const Row(
              children: [
                Icon(Icons.chat, color: Colors.deepPurpleAccent),
                SizedBox(width: 4),
                Text("Chat"),
              ],
            ),
          ),
          if (isGirlUser)
            TextButton(
              onPressed: () {
                // Handle edit/mark as solved action
              },
              child: const Row(
                children: [
                  Icon(Icons.edit, color: Colors.green),
                  SizedBox(width: 4),
                  Text("Mark as Solved"),
                ],
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaints"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Complaint>>(
        future: _complaintsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No complaints found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final complaints = snapshot.data!;
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 5,
                    backgroundColor: complaint.status ? Colors.green : Colors.red, // Dot color based on status
                  ),
                  title: Text(
                    complaint.subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Category: ${complaint.category}"),
                      Text("Location: ${complaint.location}"),
                      Text(
                          "Date: ${complaint.dateOfIncident.toLocal().toString().split(' ')[0]}"),
                      if (complaint.isAnonymous)
                        const Text(
                          "Raised anonymously",
                          style: TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () => _showComplaintDetails(complaint),
                ),
              );

            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RaiseComplaintScreen()),
          ).then((_) {
            // Refetch complaints after returning from RaiseComplaintScreen
            setState(() {
              _complaintsFuture = _fetchComplaints();
            });
          });
        },
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),

    );
  }
}
