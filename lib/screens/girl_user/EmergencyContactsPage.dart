import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceforher/utils/constants.dart';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Map<String, dynamic>> emergencyContacts = [];
  final _formKey = GlobalKey<FormState>();
  String? _name, _phone, _relation;
  bool isLoading = false; // To track loading state for add contact
  bool isDeleting = false; // To track the loading state for delete contact

  @override
  void initState() {
    super.initState();
    fetchEmergencyContacts();
  }

  Future<void> fetchEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      showError("User not authenticated");
      return;
    }

    String baseurl = Constants.baseUrl;

    try {
      final response = await http.get(
        Uri.parse('$baseurl/profiles/profile/emergencyContacts'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('debug testing ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          emergencyContacts = List<Map<String, dynamic>>.from(data['data']["emergencyContacts"]);
        });
      } else {
        showError("Failed to fetch contacts: ${response.body}");
        print("Failed to fetch contacts: ${response.body}");
      }
    } catch (e) {
      showError("Error fetching contacts: $e");
      print("Error fetching contacts: $e");
    }
  }

  Future<void> addEmergencyContact() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    if (emergencyContacts.length >= 3) {
      showError("You can only have a maximum of 3 emergency contacts.");
      return;
    }

    setState(() {
      isLoading = true; // Set loading to true when the request starts
    });

    final newContact = {"name": _name!, "phone": _phone!, "relation": _relation!};
    final updatedContacts = List<Map<String, dynamic>>.from(emergencyContacts)..add(newContact);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      showError("User not authenticated");
      setState(() {
        isLoading = false; // Set loading to false if user is not authenticated
      });
      return;
    }

    String baseurl = Constants.baseUrl;

    try {
      final response = await http.put(
        Uri.parse('$baseurl/profiles/profile/emergencyContacts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({"emergencyContacts": updatedContacts}),
      );

      print('debug testing ${response.body}');

      if (response.statusCode == 200) {
        fetchEmergencyContacts(); // Refresh contacts after successful update
        Navigator.of(context).pop(); // Close the dialog after successful add
      } else {
        showError("Failed to add contact: ${response.body}");
      }
    } catch (e) {
      showError("Error adding contact: $e");
    } finally {
      setState(() {
        isLoading = false; // Set loading to false when the request finishes
      });
    }
  }

  Future<void> deleteEmergencyContact(int index) async {
    setState(() {
      isDeleting = true; // Set loading to true when deleting
    });

    final updatedContacts = List<Map<String, dynamic>>.from(emergencyContacts)
      ..removeAt(index);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      showError("User not authenticated");
      setState(() {
        isDeleting = false; // Set loading to false if user is not authenticated
      });
      return;
    }

    String baseurl = Constants.baseUrl;

    try {
      final response = await http.put(
        Uri.parse('$baseurl/profiles/profile/emergencyContacts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({"emergencyContacts": updatedContacts}),
      );

      print('debug testing ${response.body}');

      if (response.statusCode == 200) {
        fetchEmergencyContacts(); // Refresh contacts after successful update
      } else {
        showError("Failed to delete contact: ${response.body}");
      }
    } catch (e) {
      showError("Error deleting contact: $e");
    } finally {
      setState(() {
        isDeleting = false; // Set loading to false when the request finishes
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Method to show the dialog with the contact form
  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Emergency Contact"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      onSaved: (value) => _name = value,
                      validator: (value) =>
                      value!.isEmpty ? "Name is required" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      onSaved: (value) => _phone = value,
                      validator: (value) => value!.length != 10
                          ? "Phone must be 10 digits"
                          : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Relation',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      onSaved: (value) => _relation = value,
                      validator: (value) =>
                      value!.isEmpty ? "Relation is required" : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        addEmergencyContact();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                          : Text("Add Contact", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurpleAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: emergencyContacts.length,
                itemBuilder: (context, index) {
                  final contact = emergencyContacts[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      title: Text(contact['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${contact['relation']} - ${contact['phone']}"),
                      trailing: isDeleting
                          ? CircularProgressIndicator() // Show loading animation when deleting
                          : IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteEmergencyContact(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog, // Show dialog when the FAB is pressed
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}
