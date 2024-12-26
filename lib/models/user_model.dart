class UserModel {
  final String username;
  final String email;
  final String password;
  final String userType;
  final String phoneNumber;
  final String? education;
  final String? authorityType;

  UserModel({
    required this.username,
    required this.email,
    required this.password,
    required this.userType,
    required this.phoneNumber,
    this.education,
    this.authorityType,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "email": email,
      "password": password,
      "userType": userType,
      "phoneNumber": phoneNumber,
      if (userType == "girlUser") "education": education,
      if (userType == "authority") "authorityType": authorityType,
    };
  }
}

class User {
  final String token;
  final String message;
  final String userType;

  User({required this.token, required this.message, required this.userType});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'],
      message: json['message'],
      userType: json['userType'],
    );
  }
}


