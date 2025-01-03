import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:voiceforher/screens/authority/AllCounselling.dart';
import 'package:voiceforher/screens/authority/AllUserProfiles.dart';
import 'package:voiceforher/screens/girl_user/file_upload_screen.dart';
import 'package:voiceforher/screens/girl_user/raiseComplaint.dart';
import 'package:voiceforher/screens/girl_user/requesting_help.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ComplaintScreen.dart';
import '../ImageRecog.dart';
import '../ProfileScreen.dart';
import 'ChatBoxScreen.dart';
import 'EmergencyContactsPage.dart';
import 'awarenessPage.dart';
import 'counselling.dart';
import 'package:permission_handler/permission_handler.dart';

class Homescreen extends StatefulWidget {
  final bool isAuthority;

  const Homescreen({
    required this.isAuthority,
    Key? key,
  }) : super(key: key);

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _navItems;
  late final token;

  // void getToken() async{
  //   final prefs = await SharedPreferences.getInstance();
  //   token = prefs.getString('token');
  // }


  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _requestPermissions();





    // Define pages and navigation items using dummy data
    if (widget.isAuthority) {

      _pages = [
        ComplaintListScreen(),
        AllUserProfileScreen(),
        CounsellingRequestsScreen(),
        ProfileScreen(),
      ];

      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.girl), label: 'Complaint'),
        BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle), label: 'Profiles'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Counselling'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      _pages = [
        HomePage(),
        // FileUploadScreen(),
        ImageRecognition(),
        ChatScreen(),
        ProfileScreen(),
      ];

      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.perm_identity), label: 'faceRecoginition'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }
  }

  // Function to request SMS and Phone Call permissions
  Future<void> _requestPermissions() async {
    // Request SMS and Phone permissions
    PermissionStatus smsStatus = await Permission.sms.request();
    PermissionStatus callStatus = await Permission.phone.request();
    PermissionStatus locationStatus = await Permission.location.request();

    if (smsStatus.isGranted && callStatus.isGranted) {
      // Permissions granted
      print("SMS and Phone Call permissions granted");
    } else {
      // Permissions denied
      print("SMS and/or Phone Call permissions denied");
    }
  }



  Future<void> _requestLocationPermission() async {
    LocationPermission permission;

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt the user to enable location services
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showPermissionError('Location services are disabled.');
        return;
      }
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionError('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionError(
          'Location permissions are permanently denied. Please enable them in settings.');
      return;
    }

    // Permission granted and location services enabled
    debugPrint('Location permission granted.');
  }

  void _showPermissionError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 5,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: _navItems,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          top: false,
          child: AppBar(
            flexibleSpace: ClipPath(
              clipper: CurvedAppBarClipper(),
              child: Container(
                color: Colors.deepPurpleAccent,
              ),
            ),
            title: const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.03),
            Center(
              child: Column(
                children: [
                  Container(
                    height: screenHeight * 0.2,
                    width: screenHeight * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.6),
                    ),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animation.value,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EmergencyHelpScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.all(screenHeight * 0.05),
                              ),
                              child: Icon(
                                Icons.warning_rounded,
                                size: screenHeight * 0.08,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Emergency Needed?',
                    style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Not Sure What to do?',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = screenWidth > 600 ? 3 : 2;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildCircularButton(
                          context, Icons.location_on, 'Awareness', AwarenessPage()),
                      _buildCircularButton(
                          context, Icons.group, 'Counselling', CounsellingPage()),
                      _buildCircularButton(
                          context, Icons.report, 'Complaints', ComplaintListScreen()),
                      _buildCircularButton(
                          context, Icons.contacts, 'Contacts', EmergencyContactsScreen()),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton(
      BuildContext context, IconData icon, String label, Widget page) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: screenHeight * 0.07,
            backgroundColor: Colors.deepPurpleAccent,
            child: Icon(
              icon,
              color: Colors.white,
              size: screenHeight * 0.05,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            label,
            style: TextStyle(
              fontSize: screenHeight * 0.02,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurpleAccent,
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
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}