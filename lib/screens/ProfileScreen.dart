import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceforher/models/UserProfileModel.dart';
import '../services/UserService.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<UserProfileModel>(
        future: userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileHeader(user),
                    const SizedBox(height: 20),
                    _buildDetailsCard(user),
                    const SizedBox(height: 20),
                    _buildEmergencyContacts(user.defaultEmergencyContacts, "Default Emergency Contacts"),
                    const SizedBox(height: 20),
                    _buildEmergencyContacts(user.emergencyContacts, "Emergency Contacts"),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileModel user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.indigo.shade100,
          child: Text(
            user.username[0].toUpperCase(),
            style: const TextStyle(fontSize: 40, color: Colors.indigo),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          user.username,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          user.email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(UserProfileModel user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow("Phone", user.phoneNumber),
            _buildDetailRow("User Type", user.userType),
            if (user.authorityType != null) _buildDetailRow("Authority Type", user.authorityType!),
            if (user.education != null) _buildDetailRow("Education", user.education!),
            _buildDetailRow("Is Approved", user.isApproved ? "Yes" : "No"),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts(List<EmergencyContact> contacts, String title) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ...contacts.map((e) => ListTile(
              leading: const Icon(Icons.contact_phone, color: Colors.indigo),
              title: Text(e.name),
              subtitle: Text("${e.phone} (${e.relation})"),
            )),
          ],
        ),
      ),
    );
  }
}
