import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AwarenessPage extends StatelessWidget {
  final List<Map<String, String>> videos = [
    {
      'title': 'Safety Tips for Women',
      'url': 'https://www.youtube.com/watch?v=q8MHurhUl5Q',
    },
    {
      'title': 'Self-Defense Techniques',
      'url': 'https://www.youtube.com/watch?v=RFO8rBIQQxM',
    },
    {
      'title': 'Recognizing Dangerous Situations',
      'url': 'https://www.youtube.com/watch?v=gWtuz-o45VQ',
    },
  ];

  // Helper method to extract YouTube video ID and get thumbnail URL
  String? getYouTubeThumbnail(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) return null;

    try {
      final uri = Uri.parse(videoUrl);
      if (uri.queryParameters.containsKey('v')) {
        final videoId = uri.queryParameters['v'];
        return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      }
    } catch (e) {
      // Log or handle the error
      debugPrint('Error parsing URL: $e');
    }
    return null; // Return null if video ID can't be found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Awareness Videos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            final thumbnailUrl = getYouTubeThumbnail(video['url']);

            return GestureDetector(
              onTap: () async {
                final url = video['url'];
                if (url != null && await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic thumbnail from YouTube
                    if (thumbnailUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.network(
                          thumbnailUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        video['title'] ?? 'Unknown Video',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
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
  }
}
