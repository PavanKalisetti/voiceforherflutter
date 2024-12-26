import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../utils/constants.dart';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Map<String, dynamic>> emergencyContacts = [];
  final _formKey = GlobalKey<FormState>();
  String? _name, _phone, _relation;
  bool isdataLoading = true;
  bool isLoading = false; // To track loading state for add contact
  bool isDeleting = false;
  String searchQuery = ''; // To track the loading state for delete contact
  List<Map<String, dynamic>> filteredContacts = [];

  @override
  void initState() {
    super.initState();
    fetchEmergencyContacts();
  }

  Future<void> fetchEmergencyContacts() async {
    setState(() {
      isdataLoading = true; // Show loading indicator
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');



    if (token == null) {
      showError("User not authenticated");
      setState(() {
        isdataLoading = false; // Show loading indicator
      });
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
          emergencyContacts = List<Map<String, dynamic>>.from(
              data['data']["emergencyContacts"]);

        });
      } else {
        showError("Failed to fetch contacts: ${response.body}");
        print("Failed to fetch contacts: ${response.body}");
      }
    } catch (e) {
      showError("Error fetching contacts: $e");
      print("Error fetching contacts: $e");
    }
    finally {
      setState(() {
        isdataLoading = false; // Hide loading indicator
      });
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

    final newContact = {
      "name": _name!,
      "phone": _phone!,
      "relation": _relation!
    };
    final updatedContacts = List<Map<String, dynamic>>.from(emergencyContacts)
      ..add(newContact);

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
  void filterContacts(String query) {
    setState(() {
      searchQuery = query;
      filteredContacts = emergencyContacts
          .where((contact) =>
      contact['name']
          .toLowerCase()
          .contains(query.toLowerCase()) || // Match name
          contact['relation']
              .toLowerCase()
              .contains(query.toLowerCase()) || // Match relation
          contact['phone']
              .toLowerCase()
              .contains(query.toLowerCase())) // Match phone
          .toList();
    });
  }

  // Method to show the dialog with the contact form
  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
                        labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Colors.deepPurpleAccent, width: 2),
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      onSaved: (value) => _name = value,
                      validator: (value) =>
                      value!.isEmpty ? "Name is required" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Colors.deepPurpleAccent, width: 2),
                        ),
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.deepPurpleAccent,
                        ),
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
                        labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Colors.deepPurpleAccent, width: 2),
                        ),
                        prefixIcon: Icon(
                          Icons.group,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      onSaved: (value) => _relation = value,
                      validator: (value) =>
                      value!.isEmpty ? "Relation is required" : null,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Close",
                                style:
                                TextStyle(color: Colors.deepPurpleAccent)),
                          ),
                        ),
                        SizedBox(
                          width: 35,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.deepPurpleAccent))
                                : Text("Add Contact",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
            'Emergency Contacts',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
      ),
      body: isdataLoading
          ? Center(
        child: SpinKitFadingCircle(
          color: Colors.deepPurpleAccent,
          size: 50.0,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Expanded(
              child: ListView.builder(
                itemCount: emergencyContacts.length,
                itemBuilder: (context, index) {
                  final contact = emergencyContacts[index];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      title: Text(contact['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent)),
                      subtitle: Text(
                          "${contact['relation']} - ${contact['phone']}"),
                      trailing: isDeleting
                          ? CircularProgressIndicator(color: Colors.deepPurpleAccent,) // Show loading animation when deleting
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