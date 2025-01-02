class CounsellingRequest {
  final String id;
  final String? status;
  final String? reason;
  final String? user;
  final String? authorityReason;
  final String? scheduledPlace;
  final String? scheduledDate;
  final String? scheduledTime;

  CounsellingRequest({required this.id, this.status, this.reason, this.user, this.authorityReason, this.scheduledPlace, this.scheduledDate,this.scheduledTime });

  factory CounsellingRequest.fromJson(Map<String, dynamic> json) {
    return CounsellingRequest(
      id: json['_id'],
      reason: json['reason'],
      status: json['status'],
      user: json['user'],
      authorityReason: json['authorityReason'],
      scheduledPlace: json['scheduledPlace'],
      scheduledDate: json['scheduledDate'],
      scheduledTime: json['scheduledTime'],
    );
  }
}