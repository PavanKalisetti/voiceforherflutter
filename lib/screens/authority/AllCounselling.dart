import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceforher/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../models/counselling_request.dart';
import 'package:shimmer/shimmer.dart';

class CounsellingRequestsScreen extends StatefulWidget {
  @override
  _CounsellingRequestsScreenState createState() =>
      _CounsellingRequestsScreenState();
}

class _CounsellingRequestsScreenState extends State<CounsellingRequestsScreen> {
  List<CounsellingRequest> _counsellingRequests = [];
  bool _isLoading = false;
  List<CounsellingRequest> _currentRequests = [];
  List<CounsellingRequest> _pastRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchCounsellingRequests();
  }

  Future<void> _fetchCounsellingRequests() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String baseurl = Constants.baseUrl;
    final response = await http.get(
      Uri.parse('$baseurl/counselling/getAllcounselling'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      setState(() {
        _counsellingRequests =
            data.map((json) => CounsellingRequest.fromJson(json)).toList();

        // Split the requests into current and past sessions based on status
        _currentRequests = _counsellingRequests
            .where((request) =>
                request.status == 'pending' || request.status == 'in-progress')
            .toList();
        _pastRequests = _counsellingRequests
            .where((request) =>
                request.status == 'completed' || request.status == 'rejected')
            .toList();

        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCounsellingRequestStatus(String id, String status) async {
    print(id);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String baseurl = Constants.baseUrl;
    final response = await http.put(
      Uri.parse('$baseurl/counselling/status/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': status,
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _counsellingRequests = _counsellingRequests.map((request) {
          if (request.id == id) {
            return CounsellingRequest(
              id: id,
              reason: request.reason,
              status: status,
            );
          }
          return request;
        }).toList();
      });
    }
  }

  Future<void> _rejectRequest(String id, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String baseurl = Constants.baseUrl;

    final response = await http.put(
      Uri.parse('$baseurl/counselling/details/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': 'rejected',
        'authorityReason': reason,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _counsellingRequests = _counsellingRequests.map((request) {
          if (request.id == id) {
            return CounsellingRequest(
              id: id,
              reason: request.reason,
              status: 'rejected',
              authorityReason: reason,
            );
          }
          return request;
        }).toList();

        _currentRequests = _counsellingRequests
            .where((request) =>
                request.status == 'pending' || request.status == 'in-progress')
            .toList();
        _pastRequests = _counsellingRequests
            .where((request) =>
                request.status == 'completed' || request.status == 'rejected')
            .toList();
      });
    } else {
      print('Failed to reject request');
    }
  }

  Future<void> _scheduleRequest(
      String id, String place, String date, String time) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String baseurl = Constants.baseUrl;

    final response = await http.put(
      Uri.parse('$baseurl/counselling/details/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': 'in-progress',
        'scheduledPlace': place,
        'scheduledDate': date,
        'scheduledTime': time,
      }),
    );
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _counsellingRequests = _counsellingRequests.map((request) {
          if (request.id == id) {
            return CounsellingRequest(
              id: id,
              reason: request.reason,
              status: 'in-progress',
              scheduledPlace: place,
              scheduledDate: date,
              scheduledTime: time,
            );
          }
          return request;
        }).toList();

        _currentRequests = _counsellingRequests
            .where((request) =>
                request.status == 'pending' || request.status == 'in-progress')
            .toList();
        _pastRequests = _counsellingRequests
            .where((request) =>
                request.status == 'completed' || request.status == 'rejected')
            .toList();
      });
    } else {
      print('Failed to schedule request');
    }
  }

  void _showRejectDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController reasonController = TextEditingController();
        return AlertDialog(
          title: Text('Reject Request'),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: 'Enter reason for rejection',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String reason = reasonController.text;
                if (reason.isNotEmpty) {
                  _rejectRequest(id, reason);
                  Navigator.of(context).pop();
                } else {
                  print('Reason cannot be empty');
                }
              },
              child: Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  void _showScheduleDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController placeController = TextEditingController();
        TextEditingController dateController = TextEditingController();
        TextEditingController timeController = TextEditingController();
        DateTime? selectedDate;
        TimeOfDay? selectedTime;

        return AlertDialog(
          title: Text('Schedule Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: placeController,
                decoration: InputDecoration(
                  hintText: 'Enter place',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pick Date',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                      dateController.text = DateFormat.yMMMd().format(date);
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: timeController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pick Time',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                      timeController.text = time.format(context);
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String place = placeController.text;
                String date = dateController.text;
                String time = timeController.text;

                if (selectedDate != null &&
                    selectedTime != null &&
                    place.isNotEmpty) {
                  _scheduleRequest(id, place, date, time);
                  Navigator.of(context).pop();
                } else {
                  print('Please fill in all fields');
                }
              },
              child: Text('Schedule'),
            ),
          ],
        );
      },
    );
  }

  void _showScheduledDetails(CounsellingRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Counselling Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Reason: ${request.reason ?? 'Not specified'}"),
              SizedBox(height: 8),
              Text(
                  "Scheduled Date: ${request.scheduledDate ?? 'Not specified'}"),
              SizedBox(height: 8),
              Text(
                  "Scheduled Time: ${request.scheduledTime ?? 'Not specified'}"),
              SizedBox(height: 8),
              Text(
                  "Scheduled Place: ${request.scheduledPlace ?? 'Not specified'}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Close"),
            ),
            TextButton(
              onPressed: () {
                _updateCounsellingRequestStatus(request.id, "completed");
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Completed"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          flexibleSpace: ClipPath(
            clipper: CurvedAppBarClipper(),
            child: Container(
              color: Colors.deepPurpleAccent,
            ),
          ),
          title: const Text(
            'Counselling Requests',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 10, // Number of shimmer items to show
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              },
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildRequestSection("Current Sessions", _currentRequests),
                  _buildRequestSection("Past Sessions", _pastRequests),
                ],
              ),
            ),
    );
  }

  Widget _buildRequestSection(String title, List<CounsellingRequest> requests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurpleAccent,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final statusColor = request.status == 'pending'
                ? Colors.orange
                : request.status == 'completed'
                    ? Colors.blue
                    : request.status == 'rejected'
                        ? Colors.red
                        : Colors.green;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reason: ${request.reason}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Status: ${request.status}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (request.status == 'pending')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _showRejectDialog(request.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(
                              'Reject',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showScheduleDialog(request.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(
                              'Schedule',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    if (request.status == 'in-progress')
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _showScheduledDetails(request),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            'Scheduled',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
