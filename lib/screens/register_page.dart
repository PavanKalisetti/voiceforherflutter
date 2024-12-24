import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'Login_page.dart';


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
  final TextEditingController _authorityTypeController =
  TextEditingController();

  String _userType = "girlUser";
  String? _education;
  String? _authorityType;
  bool _isLoading = false;
  bool _obscurePassword = true; // To toggle password visibility

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
      education: _userType == "girlUser" ? _education : null,
      authorityType:
      _userType == "authority" ? _authorityType : null,
    );
    print("debug testing ${_usernameController.text}");
    print("debug testing ${_emailController.text}");
    print("debug testing ${_passwordController.text}");
    print("debug testing $_userType");
    print("debug testing $_education");
    print("debug testing $_authorityType");




    // final user = UserModel(
    //   username: "rupak",
    //   email: "rupak@gmail.com",
    //   password: "rupak12345",
    //   userType: "girlUser",
    //   phoneNumber: "9701352958",
    //   education: "rgukt",
    //   authorityType: "warden",
    // );

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
      print("debug testing $error");
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
      body: ColoredBox(
        color: Colors.white,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 150),
              painter: CurvedAppBarPainter(),
            ),
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "SignUp",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStylishTextFormField(
                          controller: _usernameController,
                          label: "Username",
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Username is required";
                            return null;
                          },
                        ),
                        _buildStylishTextFormField(
                          controller: _emailController,
                          label: "Email",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Email is required";
                            // if (!RegExp(r'^\S+@\S+\.\S+\$').hasMatch(value))
                            //   return "Invalid email format";
                            return null;
                          },
                        ),
                        _buildStylishTextFormField(
                          controller: _passwordController,
                          label: "Password",
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Password is required";
                            if (value.length < 8)
                              return "Password must be at least 8 characters";
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.deepPurpleAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _userType,
                          items: [
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
                              _userType = value!;
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
                              borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
                            ),
                          ),
                          dropdownColor: Colors.white,
                        ),

                        SizedBox(height: 20),
                        _buildStylishTextFormField(
                          controller: _phoneNumberController,
                          label: "Phone Number",
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Phone number is required";
                            // if (!RegExp(r'^\d{10}\$').hasMatch(value))
                            //   return "Phone number must be 10 digits";
                            return null;
                          },
                        ),
                        if (_userType == "girlUser")
                          DropdownButtonFormField<String>(
                            value: _education,
                            items: [
                              DropdownMenuItem(
                                value: "p1",
                                child: Text("P1"),
                              ),
                              DropdownMenuItem(
                                value: "p2",
                                child: Text("P2"),
                              ),
                              DropdownMenuItem(
                                value: "e1",
                                child: Text("E1"),
                              ),
                              DropdownMenuItem(
                                value: "e2",
                                child: Text("E2"),
                              ),
                              DropdownMenuItem(
                                value: "e3",
                                child: Text("E3"),
                              ),
                              DropdownMenuItem(
                                value: "e4",
                                child: Text("E4"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _education = value;
                              });
                            },
                            hint: Text("Select Education"),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                BorderSide(color: Colors.black, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                BorderSide(color: Colors.black, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent, width: 2),
                              ),
                            ),
                            dropdownColor: Colors.white,
                          ),
                        if (_userType == "authority")
                          DropdownButtonFormField<String>(
                            value: _authorityType,
                            items: [
                              DropdownMenuItem(
                                value: "director",
                                child: Text("Director"),
                              ),
                              DropdownMenuItem(
                                value: "dsw",
                                child: Text("DSW"),
                              ),
                              DropdownMenuItem(
                                value: "warden",
                                child: Text("Warden"),
                              ),
                              DropdownMenuItem(
                                value: "caretaker",
                                child: Text("Caretaker"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _authorityType = value;
                              });
                            },
                            hint: Text("Select Authority Type"),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                BorderSide(color: Colors.black, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                BorderSide(color: Colors.black, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent, width: 2),
                              ),
                            ),
                            dropdownColor: Colors.white,
                          ),
                        SizedBox(height: 20),
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.deepPurpleAccent,
                          ),
                          child: Center(
                            child: Text(
                              "Register",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylishTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          suffixIcon: suffixIcon, // Add the suffix icon here
        ),
      ),
    );
  }
}

class CurvedAppBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.deepPurpleAccent;
    Path path = Path();

    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
