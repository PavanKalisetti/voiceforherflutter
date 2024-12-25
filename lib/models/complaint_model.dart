class Complaint {
  final String subject;
  final String description;
  final String category;
  final String location;
  final DateTime dateOfIncident;
  final bool isAnonymous;
  final bool status; // Add this field

  Complaint({
    required this.subject,
    required this.description,
    required this.category,
    required this.location,
    required this.dateOfIncident,
    this.isAnonymous = false,
    required this.status, // Mark as required
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
      "status": status, // Include status
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
      status: json['status'], // Parse status from JSON
    );
  }
}
