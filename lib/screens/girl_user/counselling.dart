import 'package:flutter/material.dart';

class CounsellingHomePage extends StatelessWidget {
  final List<Map<String, String>> counsellingSchedules = [
    {'time': 'Monday, 10:00 AM', 'place': 'Room 81, I-3 block', 'status': 'Scheduled'},
    {'time': 'Wednesday, 2:00 PM', 'place': 'Room 45, B-2 block', 'status': 'Applied'},
    {'time': 'Friday, 11:30 AM', 'place': 'Room 12, C-1 block', 'status': 'Completed'},
    {'time': 'Thursday, 4:00 PM', 'place': 'Room 20, A-1 block', 'status': 'Rejected'},
  ];



  void _showMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            message,
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Counselling Schedules',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ColoredBox(
            color: Colors.purple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: counsellingSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = counsellingSchedules[index];
                  final status = schedule['status']!;

                  // Determine the color based on the status
                  Color statusColor;
                  String displayMessage;

                  switch (status) {
                    case 'Scheduled':
                      statusColor = Colors.green;
                      displayMessage = 'Time: ${schedule['time']!}\nPlace: ${schedule['place']!}';
                      break;
                    case 'Applied':
                      statusColor = Colors.yellow;
                      displayMessage = 'You have applied for counselling.';
                      break;
                    case 'Completed':
                      statusColor = Colors.blue;
                      displayMessage = 'Time: ${schedule['time']!}\nPlace: ${schedule['place']!}';
                      break;
                    case 'Rejected':
                      statusColor = Colors.red;
                      displayMessage = 'Your application was rejected.';
                      break;
                    default:
                      statusColor = Colors.grey;
                      displayMessage = 'No details available.';
                  }

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: statusColor,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: constraints.maxWidth > 600 ? 18 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            displayMessage,
                            style: TextStyle(
                              fontSize: constraints.maxWidth > 600 ? 18 : 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show the message dialog
          _showMessageDialog(context, 'Check after some time for scheduling details');
        },
        label: Text(
          'Apply',
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
