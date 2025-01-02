import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceforher/utils/constants.dart';
import 'package:shimmer/shimmer.dart';

class AllUserProfileScreen extends StatefulWidget {
  const AllUserProfileScreen({super.key});

  @override
  _AllUserProfileScreenState createState() => _AllUserProfileScreenState();
}

class _AllUserProfileScreenState extends State<AllUserProfileScreen> {
  List<dynamic> allUsers = [];
  List<dynamic> filteredUsers = [];
  String selectedFilter = "All"; // Default filter
  bool isLoading = true;
  final String apiUrl = Constants.baseUrl;
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
      final response = await http.get(
        Uri.parse('$apiUrl/profiles/allprofiles'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          allUsers = json.decode(response.body)['data'];
          filteredUsers = allUsers; // Initialize with all users
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void filterUsers() {
    setState(() {
      if (selectedFilter == "All") {
        filteredUsers = allUsers;
      } else {
        filteredUsers = allUsers
            .where((user) => user['userType'] == selectedFilter)
            .toList();
      }
    });
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('User approved successfully'),
              backgroundColor: Colors.green),
        );
        fetchAllUsers(); // Refresh the list
      } else {
        throw Exception('Failed to approve user');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          top: false,
          child: AppBar(
            flexibleSpace: ClipPath(
              clipper: CurvedAppBarClipper(),
              child: Container(
                color: Colors.deepPurpleAccent,
              ),
            ),
            title: const Text(
              'All User Profiles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField(
                focusColor: Colors.deepPurpleAccent,

                value: selectedFilter,
                isExpanded: true,
                // Text style in dropdown
                items: const [
                  DropdownMenuItem(
                    value: "All",
                    child: Row(
                      children: [
                        Icon(Icons.group, color: Colors.deepPurpleAccent),
                        SizedBox(width: 8),
                        Text("All Users"),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: "girlUser",
                    child: Row(
                      children: [
                        Icon(Icons.female, color: Colors.deepPurpleAccent),
                        SizedBox(width: 8),
                        Text("Girl User"),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: "authority",
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.deepPurpleAccent),
                        SizedBox(width: 8),
                        Text("Authority"),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                    filterUsers();
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: Colors.deepPurpleAccent, width: 2),
                  ),
                ),
                dropdownColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? ListView.builder(
                    itemCount: 10, // Number of shimmer items to show
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : filteredUsers.isEmpty
                    ? const Center(
                        child: Text("No users found"),
                      )
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                user['username'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              subtitle: Text(
                                user['email'],
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              trailing: user['isApproved']
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : ElevatedButton(
                                      onPressed: () => approveUser(user['_id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text('Approve',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                              onTap: () => showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(user["userType"]),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Username: ${user['username']}'),
                                          const SizedBox(height: 10),
                                          Text('Email: ${user['email']}'),
                                          const SizedBox(height: 10),
                                          Text(
                                              'Phone: ${user['phoneNumber'] ?? 'N/A'}'),
                                          const SizedBox(height: 10),
                                          if (user["userType"] == "authority")
                                            Text(
                                                'Authority Type: ${user['authorityType'] ?? 'N/A'}'),
                                          if (user["userType"] == "girlUser")
                                            Text(
                                                'Education: ${user['education'] ?? 'N/A'}'),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
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
