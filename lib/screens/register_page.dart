import 'package:flutter/material.dart';
import 'package:voiceforher/screens/Login_page.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _authorityTypeController = TextEditingController();

  String _userType = "girlUser";
  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final user = UserModel(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      userType: _userType,
      phoneNumber: _phoneNumberController.text,
      education: _userType == "girlUser" ? _educationController.text : null,
      authorityType: _userType == "authority" ? _authorityTypeController.text : null,
    );

    try {
      final response = await ApiService.registerUser(user);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response['message']),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: "Username"),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Username is required";
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email is required";
                    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(value)) return "Invalid email format";
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password is required";
                    if (value.length < 8) return "Password must be at least 8 characters";
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _userType,
                  items: [
                    DropdownMenuItem(value: "girlUser", child: Text("Girl User")),
                    DropdownMenuItem(value: "authority", child: Text("Authority")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _userType = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: "User Type"),
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Phone number is required";
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) return "Phone number must be 10 digits";
                    return null;
                  },
                ),
                if (_userType == "girlUser")
                  TextFormField(
                    controller: _educationController,
                    decoration: InputDecoration(labelText: "Education"),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Education is required";
                      return null;
                    },
                  ),
                if (_userType == "authority")
                  TextFormField(
                    controller: _authorityTypeController,
                    decoration: InputDecoration(labelText: "Authority Type"),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Authority type is required";
                      return null;
                    },
                  ),
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _registerUser,
                  child: Text("Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
