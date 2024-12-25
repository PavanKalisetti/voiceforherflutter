class UserProfileModel {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String userType;
  final String? authorityType;
  final String? education;
  final bool isApproved;
  final List<EmergencyContact> defaultEmergencyContacts;
  final List<EmergencyContact> emergencyContacts;

  UserProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    this.authorityType,
    this.education,
    required this.isApproved,
    required this.defaultEmergencyContacts,
    required this.emergencyContacts,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      userType: json['userType'],
      authorityType: json['authorityType'],
      education: json['education'],
      isApproved: json['isApproved'],
      defaultEmergencyContacts: (json['defaultEmergencyContacts'] as List)
          .map((e) => EmergencyContact.fromJson(e))
          .toList(),
      emergencyContacts: (json['emergencyContacts'] as List)
          .map((e) => EmergencyContact.fromJson(e))
          .toList(),
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relation;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      phone: json['phone'],
      relation: json['relation'],
    );
  }
}
