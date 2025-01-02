import 'package:flutter/material.dart';
import 'package:voiceforher/utils/constants.dart';
// import 'package:voiceforher/screens/girl_user/raiseComplaint.dart';
import '../../models/complaint_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:crypto/crypto.dart';

import '../services/ComplaintServices.dart';
import 'ChatWithAuthority.dart';
import 'girl_user/raiseComplaint.dart';
// import '../services/ComplaintServices.dart';
// import 'ChatWithAuthority.dart';
import 'package:shimmer/shimmer.dart';

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({Key? key}) : super(key: key);

  @override
  _ComplaintListScreenState createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  late Future<List<Complaint>> _complaintsFuture;

  bool isAuthority = false;

  String hashEmail(String email) {
    // Convert the email string to a list of bytes
    var bytes = utf8.encode(email);

    // Use SHA-256 to hash the email
    var digest = sha256.convert(bytes);

    // Return the hash as a hexadecimal string
    return digest.toString();
  }

  @override
  void initState() {
    super.initState();
    _checkUserType();
    _complaintsFuture = _fetchComplaints();
  }

  Future<void> _checkUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAuthority = prefs.getBool('isAuthority') ?? false;
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
      backgroundColor: Colors.white,
      title: Text(
        complaint.subject,
        style: const TextStyle(color: Colors.deepPurpleAccent, fontSize: 20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Category: ${complaint.category}"),
          SizedBox(height: 2),
          Text("Location: ${complaint.location}"),
          Text("Date: ${complaint.dateOfIncident.toLocal().toString().split(' ')[0]}"),
          SizedBox(height: 2),
          Text("Description: ${complaint.description}"),
          SizedBox(height: 2),
          if (complaint.isAnonymous)
            const Text(
              "Raised anonymously",
              style: TextStyle(color: Colors.deepPurpleAccent),
            ),
        ],
      ),
      actions: [
        if (!complaint.status) // Only show chat option if not solved
          TextButton(
            onPressed: () {
              String? email = complaint.email;
              if (email != null) {
                String hashedEmail = hashEmail(email);
                String userid = hashedEmail;
                String officerid = "officerId";

                if (isAuthority) {
                  userid = "officerId";
                  officerid = hashedEmail;
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPage(
                              userId: userid,
                              authorityId: officerid,
                              hashedemail: hashedEmail,
                            ))); 
              }
            },
            child: Row(
              children: [
                Icon(Icons.chat, color: Colors.deepPurpleAccent),
                SizedBox(width: 4),
                if (isAuthority)
                  Text("Chat with girlUser", style: TextStyle(color: Colors.black)),
                if (!isAuthority)
                  Text("Chat with Authority", style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        if (!isAuthority && !complaint.status) // "Mark as Solved" button only for unsolved complaints
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');
              final response = await http.put(
                Uri.parse('${Constants.baseUrl}/complaint/complaints/${complaint.id}/mark-as-solved'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );

              if (response.statusCode == 200) {
                setState(() {
                  complaint.status = true; // Update the local state
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Complaint marked as solved!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to mark complaint as solved')),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Row(
              children: [
                Icon(Icons.edit, color: Colors.deepPurpleAccent),
                SizedBox(width: 4),
                Text("Mark as Solved", style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close", style: TextStyle(color: Colors.deepPurpleAccent)),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildShimmerEffect() {
    return ListView(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 20,
              width: MediaQuery.of(context).size.width / 2,
              color: Colors.white,
            ),
          ),
        ),
        ...List.generate(4, (index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        }),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 20,
              width: MediaQuery.of(context).size.width / 2,
              color: Colors.white,
            ),
          ),
        ),
        ...List.generate(4, (index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildComplaintList(List<Complaint> complaints) {
    if (complaints.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          "No complaints found.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(
              Icons.report_problem,
              color: complaint.status ? Colors.green : Colors.yellow,
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
                // Text("Category: ${complaint.category}"),
                // Text("Location: ${complaint.location}"),
                Text(
                    "Date: ${complaint.dateOfIncident.toLocal().toString().split(' ')[0]}"),
                // if (complaint.isAnonymous)
                //   const Text(
                //     "Raised anonymously",
                //     style: TextStyle(color: Colors.grey),
                //   ),
              ],
            ),
            isThreeLine: true,
            onTap: () => _showComplaintDetails(complaint),
          ),
        );
      },
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
            'Complaint Box',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
      ),
      body: FutureBuilder<List<Complaint>>(
        future: _complaintsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Shimmer loading effect
            return _buildShimmerEffect();
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
          final currentComplaints =
          complaints.where((complaint) => !complaint.status).toList();
          final pastComplaints =
          complaints.where((complaint) => complaint.status).toList();

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "Current Complaints",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ),
              _buildComplaintList(currentComplaints),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "Past Complaints",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ),
              _buildComplaintList(pastComplaints),
            ],
          );
        },
      ),
      floatingActionButton: !isAuthority
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const RaiseComplaintScreen()),
          ).then((_) {
            // Refetch complaints after returning from RaiseComplaintScreen
            setState(() {
              _complaintsFuture = _fetchComplaints();
            });
          });
        },
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
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
