import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/models/UserProfileModel.dart';
import '/services/UserService.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, Map<String, dynamic>>> _messages = [];
  bool _isLoading = false;
  String? _userName; // To store the user's name

  // Initialize the GenerativeModel
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'AIzaSyAhLLGhk8WB8KERuuXFG6-w5C7FG--JYtc', // Replace with your actual API key
  );

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Fetch the user's name from the backend
  Future<void> _fetchUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isNotEmpty) {
        final userProfile = await UserService.fetchUserProfile(token);
        setState(() {
          _userName = userProfile.username; // Adjust based on your model's property
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No token found, please login again.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user name: $error')),
      );
    }
  }

  // Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('hh:mm a').format(timestamp);
  }

  // Function to send a message and get a response from the bot
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message cannot be empty")),
      );
      return;
    }

    // Add user's message to the chat
    setState(() {
      _messages.add({
        'user': {
          'content': content,
          'timestamp': DateTime.now(),
        }
      });
      _isLoading = true;
    });

    try {
      // Construct the dynamic prompt
      String ExtraPrompt = _userName != null
          ? "You are a caring and supportive virtual friend named Mitra. Your job is to uplift $_userName, who may be feeling low or mentally overwhelmed. Use short, sweet, and encouraging responses.Clarify all the user doubts. Make sure you give some tips on women safety for the user and how to tackle emergency situations . Use your database to clarify his/her doubts . Keep the tone warm and supportive, like a close friend, and make the responses short and concise. The below is the user prompt:"
          : "You are a caring and supportive virtual friend named Mitra. Your job is to uplift the user. Use short, sweet, and encouraging responses. Always be positive, empathetic, and kind. The below is the user prompt:";

      final response =
      await model.generateContent([Content.text(ExtraPrompt + content)]);

      // Add bot's response to the chat
      setState(() {
        _messages.add({
          'bot': {
            'content': response.text ?? 'No response from the server.',
            'timestamp': DateTime.now(),
          }
        });
      });
    } catch (e) {
      // Handle error and show a message
      setState(() {
        _messages.add({
          'bot': {
            'content': 'Error: $e',
            'timestamp': DateTime.now(),
          }
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            'Mitra AI Chatbot',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.containsKey('user');
                final sender = isUser ? 'user' : 'bot';
                final content = message[sender]!['content'] as String;
                final timestamp = message[sender]!['timestamp'] as DateTime;

                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 250),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.deepPurpleAccent.shade100
                          : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isUser
                            ? const Radius.circular(12)
                            : const Radius.circular(0),
                        bottomRight: isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _formatTimestamp(timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading indicator
          if (_isLoading) const LinearProgressIndicator(),

          // Input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.purple,
                  onPressed: () {
                    final content = _messageController.text.trim();
                    if (content.isNotEmpty) {
                      sendMessage(content);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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