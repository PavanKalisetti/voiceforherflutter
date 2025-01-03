import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/UserProfileModel.dart';
import '../services/UserService.dart';
import 'Login_page.dart'; // Replace with your actual login screen import
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<UserProfileModel>? userProfile;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchUserProfile();
  }

  void _loadTokenAndFetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isNotEmpty) {
      setState(() {
        userProfile = UserService.fetchUserProfile(token);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found, please login again.')),
      );
      setState(() {
        userProfile = Future.error('No token found, please login again.');
      });
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => _logout(context),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored preferences (including token)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
              'Profile',
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
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<UserProfileModel>(
        future: userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.01,
                horizontal: size.width * 0.04,
              ),
              child: Column(
                children: [
                  _buildShimmerProfileHeader(size),
                  SizedBox(height: size.height * 0.02),
                  _buildShimmerDetailsCard(size),
                  SizedBox(height: size.height * 0.02),
                  _buildShimmerEmergencyContacts(size),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final user = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                  horizontal: size.width * 0.04,
                ),
                child: Column(
                  children: [
                    _buildProfileHeader(user, size),
                    SizedBox(height: size.height * 0.02),
                    _buildDetailsCard(user, size),
                    SizedBox(height: size.height * 0.02),
                    if (user.userType == "girlUser") ...[
                      _buildEmergencyContacts(user.defaultEmergencyContacts, "Default Emergency Contacts", size),
                      SizedBox(height: size.height * 0.02),
                      _buildEmergencyContacts(user.emergencyContacts, "Emergency Contacts", size),
                    ],

                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildShimmerProfileHeader(Size size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          CircleAvatar(
            radius: size.width * 0.12,
            backgroundColor: Colors.grey[300],
          ),
          SizedBox(height: size.height * 0.01),
          Container(
            height: size.height * 0.02,
            width: size.width * 0.4,
            color: Colors.grey[300],
          ),
          SizedBox(height: size.height * 0.01),
          Container(
            height: size.height * 0.015,
            width: size.width * 0.3,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerDetailsCard(Size size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            children: List.generate(
              4,
                  (index) => Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.008),
                child: Container(
                  height: size.height * 0.02,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEmergencyContacts(Size size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              3,
                  (index) => Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                child: Row(
                  children: [
                    Container(
                      height: size.width * 0.05,
                      width: size.width * 0.05,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: Container(
                        height: size.height * 0.02,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileModel user, Size size) {
    return Column(
      children: [
        CircleAvatar(
          radius: size.width * 0.12,
          backgroundColor: Colors.indigo.shade100,
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(fontSize: size.width * 0.07, color: Colors.indigo),
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          user.username,
          style: TextStyle(fontSize: size.width * 0.045, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: size.height * 0.005),
        Text(
          user.email,
          style: TextStyle(fontSize: size.width * 0.035, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(UserProfileModel user, Size size) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          children: [
            _buildDetailRow("Phone", user.phoneNumber, size),
            _buildDetailRow("User Type", user.userType, size),
            if (user.authorityType != null) _buildDetailRow("Authority Type", user.authorityType!, size),
            if (user.education != null) _buildDetailRow("Education", user.education!, size),
            _buildDetailRow("Is Approved", user.isApproved ? "Yes" : "No", size),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.008),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: size.width * 0.04),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey, fontSize: size.width * 0.035),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts(List<EmergencyContact> contacts, String title, Size size) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.width * 0.045),
            ),
            SizedBox(height: size.height * 0.01),
            ...contacts.map((e) => ListTile(
              leading: Icon(Icons.contact_phone, color: Colors.deepPurpleAccent, size: size.width * 0.05),
              title: Text(e.name, style: TextStyle(fontSize: size.width * 0.04)),
              subtitle: Text(
                "${e.phone} (${e.relation})",
                style: TextStyle(fontSize: size.width * 0.035, color: Colors.grey),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}