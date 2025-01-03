class FaceRecog {
  final String branch;
  final String? email;
  final String? gender;
  final String? idNumber;
  final String? name;
  final String? phoneNumber;
  final String? year;

  FaceRecog({required this.branch, this.email, this.gender, this.idNumber, this.name, this.phoneNumber, this.year });

  Map<String, dynamic> toMap() {
    return {
      "branch": branch, // Use `_id` for database compatibility
      "email": email,
      "gender": gender,
      "idNumber": idNumber,
      "name": name,
      "phoneNumber": phoneNumber,
      "year": year,
    };
  }

  factory FaceRecog.fromJson(Map<String, dynamic> json) {
    return FaceRecog(
      branch: json['branch'],
      email: json['email'],
      gender: json['gender'],
      idNumber: json['idNumber'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      year: json['year'],
    );
  }
}