import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/complaint_model.dart';
import '../../services/ComplaintServices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RaiseComplaintScreen extends StatefulWidget {
  const RaiseComplaintScreen({super.key});

  @override
  _RaiseComplaintScreenState createState() => _RaiseComplaintScreenState();
}

class _RaiseComplaintScreenState extends State<RaiseComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<String> _categories = [
    "Verbal Abuse",
    "Sexual Harassment",
    "Bullying",
    "Stalking",
    "Cyber Harassment",
    "Discrimination",
    "Abuse of Authority",
  ];
  late final String? token;
  String? _selectedCategory;
  DateTime? _selectedDate;
  bool _isAnonymous = false;
  bool _isLoading = false;

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate() &&
        _selectedCategory != null &&
        _selectedDate != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final complaint = Complaint(
          subject: _subjectController.text,
          description: _descriptionController.text,
          category: _selectedCategory!,
          location: _locationController.text,
          dateOfIncident: _selectedDate!,
          isAnonymous: _isAnonymous,
        );

        await ComplaintService().raiseComplaint(
          token: token!,
          complaint: complaint,
        );

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Complaint raised successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to raise complaint: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Raise Complaint"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: "Subject",
                    labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Subject is required" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 4,
                  validator: (value) =>
                  value!.isEmpty ? "Description is required" : null,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Category",
                    labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                  validator: (value) =>
                  value == null ? "Category is required" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: "Location",
                    labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Location is required" : null,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() => _selectedDate = pickedDate);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.deepPurpleAccent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            "Select Date of Incident",
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "${_selectedDate!.toLocal()}".split(' ')[0],
                          style: TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  value: _isAnonymous,
                  onChanged: (value) =>
                      setState(() => _isAnonymous = value),
                  title: Text(
                    "Raise as Anonymous",
                    style: TextStyle(color: Colors.deepPurpleAccent),
                  ),
                  activeColor: Colors.deepPurpleAccent,
                ),
                SizedBox(height: 16),
                _isLoading
                    ? Center(
                  child: SpinKitFadingCircle(
                    color: Colors.deepPurpleAccent,
                    size: 50.0,
                  ),
                )
                    : ElevatedButton(
                  onPressed: _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    elevation: 5,
                  ),
                  child: Text(
                    "Submit Complaint",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
