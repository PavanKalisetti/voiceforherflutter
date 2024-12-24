import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:voiceforher/screens/girl_user/raiseComplaint.dart';
import 'package:voiceforher/screens/girl_user/requesting_help.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ComplaintScreen.dart';
import 'awarenessPage.dart';
import 'counselling.dart';

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


  @override
  void initState() {
    super.initState();
    _requestLocationPermission();



    // Define pages and navigation items using dummy data
    if (widget.isAuthority) {
      _pages = [
        ComplaintsScreen(),
        ProfilesPage(),
        ChatScreen(),
        ProfileScreen(),
      ];

      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.girl), label: 'Complaint'),
        BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle), label: 'Profiles'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      _pages = [
        HomePage(),
        NotificationsInApp(),
        ChatScreen(),
        ProfileScreen(),
      ];

      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
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

class HomePage extends StatelessWidget {

  final List<Map<String, String>> videos = [
    {
      'title': 'Safety Tips for Women',
      'thumbnail': 'https://www.goaid.in/wp-content/uploads/2024/05/Womens-Safety-in-India.png',
    },
    {
      'title': 'Self-Defense Techniques',
      'thumbnail': 'https://static.wixstatic.com/media/ff1c35_13ea0865e8854ff5ae11a8df5ed74724~mv2.jpg/v1/fill/w_568,h_318,al_c,q_80,usm_0.66_1.00_0.01,enc_auto/ff1c35_13ea0865e8854ff5ae11a8df5ed74724~mv2.jpg',
    },
    {
      'title': 'Recognizing Dangerous Situations',
      'thumbnail': 'https://cdn.educba.com/academy/wp-content/uploads/2023/12/Safety-of-Women-in-India.jpg',
    },
    {
      'title': 'Safety Tips for Women',
      'thumbnail': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAsYjRK7fvrUT3636STrYYGj5aGn5P8FNDjg&s',
    },
    {
      'title': 'Self-Defense Techniques',
      'thumbnail': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSTSLGPnytG-Y7GfTrYsaeR_onl3PewbCffeg&s',
    },
    {
      'title': 'Recognizing Dangerous Situations',
      'thumbnail': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT-1pGyLusrPyi-NgYxsdioIrpLTlUCsYuTQg&s',
    },
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Center(
          child: Container(
            color: Colors.deepPurple.shade50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Horizontal Scroll Section
                // Enhanced Slider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: VideoSlider(videos: videos),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [

                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_)=> EmergencyHelpScreen()),
                          );
                        },
                        child: Icon(
                          Icons.warning_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.all(30),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Emergency Needed?',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Not Sure What to do?',
                        style: TextStyle(fontSize: 18, color: Colors.deepPurpleAccent),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.all(16.0),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      //       _buildCircularButton(context, Icons.location_on, 'Safe Zone', MapScreen()),
                      //       _buildCircularButton(context, Icons.group, 'She Mate', MapScreen()),
                      //       _buildCircularButton(context, Icons.map, 'Safe Pathways', MapScreen()),
                      //     ],
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCircularButton(context, Icons.location_on,
                                'Awareness', AwarenessPage()),
                            _buildCircularButton(context, Icons.group,
                                'Counselling', CounsellingHomePage()),

                          ],
                        ),
                      ),

                      SizedBox(height: 16),
                      _buildRectangularButton(context, Icons.report, 'Complaint Box', ComplaintListScreen()),
                      _buildRectangularButton(context, Icons.contacts, 'Emergency Contacts', RaiseComplaintScreen()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCircularButton(BuildContext context, IconData icon, String label, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.deepPurpleAccent, // Consistent color
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildRectangularButton(BuildContext context, IconData icon, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent, // Adjusted for consistency
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AddContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Contacts', style: TextStyle(color: Colors.white)), backgroundColor: Colors.deepPurpleAccent),
      body: Center(child: Text('Add Contacts Page', style: TextStyle(color: Colors.deepPurpleAccent))),
    );
  }
}


// VideoSlider Component
class VideoSlider extends StatefulWidget {
  final List<Map<String, String>> videos;

  VideoSlider({required this.videos});

  @override
  _VideoSliderState createState() => _VideoSliderState();
}
class _VideoSliderState extends State<VideoSlider> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);

    // Auto-slide every 3 seconds
    Future.delayed(Duration(seconds: 3), _autoSlide);
  }

  void _autoSlide() {
    if (_currentPage < widget.videos.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;  // Loop back to the first item
    }
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
    Future.delayed(Duration(seconds: 3), _autoSlide);  // Repeat after delay
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // Adjust height for the slider
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: widget.videos.length,
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: _currentPage == index ? 0 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    video['thumbnail']!,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        video['title']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


// Dummy screen placeholders
class ComplaintsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Complaints Screen')));
  }
}

class ProfilesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Profiles Page')));
  }
}

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Chat Screen')));
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Profile Screen')));
  }
}

class NotificationsInApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Notifications')));
  }
}


