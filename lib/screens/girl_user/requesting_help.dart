import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:direct_call_plus/direct_call_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../services/SendSmsMessage.dart';
import '../../utils/constants.dart';

class EmergencyHelpScreen extends StatefulWidget {
  const EmergencyHelpScreen({super.key});

  @override
  State<EmergencyHelpScreen> createState() => _EmergencyHelpScreenState();
}

class _EmergencyHelpScreenState extends State<EmergencyHelpScreen> {
  List<Map<String, dynamic>> emergencyContacts = [];
  int countdown = 5; // Start countdown from 5 seconds
  bool timerExpired = false;
  bool callPlaced = false; // Track if a call has already been placed
  Timer? countdownTimer;

  Future<void> fetchEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      showError("User not authenticated");
      return;
    }

    String baseurl = Constants.baseUrl;

    try {
      final response = await http.get(
        Uri.parse('$baseurl/profiles/profile/emergencyContacts'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          emergencyContacts = List<Map<String, dynamic>>.from(
              data['data']["emergencyContacts"]);
        });
      } else {
        showError("Failed to fetch contacts: ${response.body}");
      }
    } catch (e) {
      showError("Error fetching contacts: $e");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchEmergencyContacts();
    if (!callPlaced) {
      startCountdown();
    }
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        setState(() {
          timerExpired = true;
        });
        timer.cancel();
        _callNumber();
        SendSmsMessage s = SendSmsMessage();
        s.sendSMSWithLocation(emergencyContacts);
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void stopCountdown() {
    if (countdownTimer != null && countdownTimer!.isActive) {
      countdownTimer!.cancel();
    }
    setState(() {
      countdown = 0;
    });
  }

  Future<void> _callNumber() async {
    if (emergencyContacts.isEmpty || callPlaced) return;

    stopCountdown();

    setState(() {
      callPlaced = true; // Mark the call as placed
      countdown = 0; // Set the timer to zero
      timerExpired = true; // Update the UI to reflect timer expiry
    });

    var number = emergencyContacts[0]["phone"];
    bool? result = await DirectCallPlus.makeCall(number);

    if (result == null || !result) {
      debugPrint('Call could not be initiated.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: timerExpired ? Colors.red : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Emergency Help',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer Circle with Countdown
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: timerExpired ? Colors.red[100] : Colors.purple[100],
                shape: BoxShape.circle,
                border: Border.all(
                  color: timerExpired ? Colors.red : Colors.purple,
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  '$countdown',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: timerExpired ? Colors.red : Colors.purple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sharing Your Location Text
            Text(
              'Sharing Your Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: timerExpired ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Notifying the police and your emergency contacts',
              style: TextStyle(
                fontSize: 14,
                color: timerExpired ? Colors.white70 : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            // Cancel and Go Ahead Buttons
            ElevatedButton(
              onPressed: () {
                stopCountdown();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('Cancel Request'),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _callNumber();
              },
              child: Text(
                'Go Ahead',
                style: TextStyle(
                  color: timerExpired ? Colors.white : Colors.purple,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}