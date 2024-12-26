class Complaint {
  final String? id; // ID field to map database `_id`
  final String subject;
  final String description;
  final String category;
  final String location;
  final DateTime dateOfIncident;
  final bool isAnonymous;
  bool status;
  final String? email; // Optional email field

  Complaint({
    this.id, // Map `_id` from the database
    required this.subject,
    required this.description,
    required this.category,
    required this.location,
    required this.dateOfIncident,
    this.isAnonymous = false,
    required this.status,
    this.email,
  });

  // Convert Complaint object to a map for API requests
  Map<String, dynamic> toMap() {
    return {
      "_id": id, // Use `_id` for database compatibility
      "subject": subject,
      "description": description,
      "category": category,
      "location": location,
      "dateOfIncident": dateOfIncident.toIso8601String(),
      "isAnonymous": isAnonymous,
      "status": status,
      "email": email,
    };
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['_id'], // Parse `_id` from JSON
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
