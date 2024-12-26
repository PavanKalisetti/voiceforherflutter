class Complaint {
  final String subject;
  final String description;
  final String category;
  final String location;
  final DateTime dateOfIncident;
  final bool isAnonymous;
  final bool status;
  final String? email; // Add email field

  Complaint({
    required this.subject,
    required this.description,
    required this.category,
    required this.location,
    required this.dateOfIncident,
    this.isAnonymous = false,
    required this.status,
    this.email, // Add email as optional
  });

  // Convert Complaint object to a map for API requests
  Map<String, dynamic> toMap() {
    return {
      "subject": subject,
      "description": description,
      "category": category,
      "location": location,
      "dateOfIncident": dateOfIncident.toIso8601String(),
      "isAnonymous": isAnonymous,
      "status": status,
      "email": email, // Include email
    };
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      subject: json['subject'],
      description: json['description'],
      category: json['category'],
      location: json['location'],
      dateOfIncident: DateTime.parse(json['dateOfIncident']),
      isAnonymous: json['isAnonymous'],
      status: json['status'],
      email: json['email'], // Parse email from JSON
    );
  }
}
