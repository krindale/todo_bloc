import 'package:flutter/material.dart';
import 'webview_screen.dart';

class SavedLinksScreen extends StatelessWidget {
  final List<Map<String, dynamic>> savedLinks = [
    {
      'title': 'The Future of AI in Healthcare',
      'url': 'pub.dev/packages/webview_flutter',
      'category': 'Technology',
      'color': Colors.green
    },
    {
      'title': '10 Best Educational Games for Kids',
      'url': 'flutter.dev',
      'category': 'Education',
      'color': Colors.brown
    },
    {
      'title': 'Latest Movie Reviews and Ratings',
      'url': 'developer.android.com/',
      'category': 'Entertainment',
      'color': Colors.orange
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: savedLinks.length,
        itemBuilder: (context, index) {
          final link = savedLinks[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewScreen(url: 'https://${link['url']}', title: link['title'],)
                ),
              );
            },
            child: Card(
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  spacing: 12,
                  children: [
                    Icon(Icons.circle, color: link['color'], size: 8),
                    Expanded(
                      child: Column(
                        spacing: 6,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(link['title'],
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(link['url'], style: TextStyle(color: Colors.blue)),
                          Chip(label: Text(link['category']), backgroundColor: link['color']!.withOpacity(0.2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}