import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/saved_link.dart';
import '../services/saved_link_repository.dart';
import 'webview/webview_screen.dart';

class SavedLinksScreen extends StatefulWidget {
  const SavedLinksScreen({super.key});

  @override
  State<SavedLinksScreen> createState() => _SavedLinksScreenState();
}

class _SavedLinksScreenState extends State<SavedLinksScreen> {
  final SavedLinkRepository _repository = SavedLinkRepository();
  List<SavedLink> savedLinks = [];

  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  Future<void> _initRepository() async {
    await _repository.init();
    _loadLinks();
  }

  void _loadLinks() async {
    final links = await _repository.getAllLinks();
    setState(() {
      savedLinks = links;
    });
  }

  Future<String> _fetchWebTitle(String url) async {
    try {
      // URL 정규화
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        String html = response.body;
        RegExp titleRegex = RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false, dotAll: true);
        Match? match = titleRegex.firstMatch(html);
        
        if (match != null) {
          String title = match.group(1)?.trim() ?? '';
          // HTML 엔티티 디코딩 (기본적인 것들만)
          title = title.replaceAll('&amp;', '&')
                      .replaceAll('&lt;', '<')
                      .replaceAll('&gt;', '>')
                      .replaceAll('&quot;', '"')
                      .replaceAll('&#39;', "'");
          return title.isNotEmpty ? title : _getDefaultTitle(url);
        }
      }
    } catch (e) {
      print('웹 타이틀 가져오기 실패: $e');
    }
    
    return _getDefaultTitle(url);
  }

  String _getDefaultTitle(String url) {
    try {
      Uri uri = Uri.parse(url);
      String domain = uri.host.toLowerCase();
      
      if (domain.contains('youtube.com') || domain.contains('youtu.be')) {
        return 'YouTube';
      } else if (domain.contains('github.com')) {
        return 'GitHub';
      } else if (domain.contains('stackoverflow.com')) {
        return 'Stack Overflow';
      } else if (domain.contains('medium.com')) {
        return 'Medium';
      } else if (domain.contains('flutter.dev')) {
        return 'Flutter';
      } else if (domain.contains('pub.dev')) {
        return 'Pub.dev';
      } else {
        String cleanDomain = domain.replaceFirst('www.', '');
        List<String> parts = cleanDomain.split('.');
        if (parts.isNotEmpty) {
          String siteName = parts[0];
          return siteName[0].toUpperCase() + siteName.substring(1);
        }
      }
      return 'Web Link';
    } catch (e) {
      return 'Web Link';
    }
  }

  String _categorizeUrl(String url) {
    String lowerUrl = url.toLowerCase();
    
    if (lowerUrl.contains('youtube') || lowerUrl.contains('netflix') || 
        lowerUrl.contains('twitch') || lowerUrl.contains('entertainment')) {
      return 'Entertainment';
    } else if (lowerUrl.contains('github') || lowerUrl.contains('stackoverflow') ||
               lowerUrl.contains('developer') || lowerUrl.contains('flutter') ||
               lowerUrl.contains('pub.dev')) {
      return 'Technology';
    } else if (lowerUrl.contains('edu') || lowerUrl.contains('course') ||
               lowerUrl.contains('learn') || lowerUrl.contains('tutorial')) {
      return 'Education';
    } else if (lowerUrl.contains('news') || lowerUrl.contains('cnn') ||
               lowerUrl.contains('bbc') || lowerUrl.contains('reuters')) {
      return 'News';
    } else if (lowerUrl.contains('facebook') || lowerUrl.contains('twitter') ||
               lowerUrl.contains('instagram') || lowerUrl.contains('linkedin')) {
      return 'Social';
    } else if (lowerUrl.contains('amazon') || lowerUrl.contains('shop') ||
               lowerUrl.contains('store') || lowerUrl.contains('buy')) {
      return 'Shopping';
    } else {
      return 'Other';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Technology':
        return Colors.blue;
      case 'Entertainment':
        return Colors.orange;
      case 'Education':
        return Colors.green;
      case 'News':
        return Colors.red;
      case 'Social':
        return Colors.purple;
      case 'Shopping':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _addNewLink() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('새 링크 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      hintText: 'https://example.com 또는 example.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    autofocus: true,
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('웹페이지 정보를 가져오는 중...'),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.of(context).pop();
                    _urlController.clear();
                  },
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_urlController.text.isNotEmpty) {
                      setStateDialog(() {
                        _isLoading = true;
                      });
                      
                      String url = _urlController.text.trim();
                      String title = await _fetchWebTitle(url);
                      String category = _categorizeUrl(url);
                      Color color = _getCategoryColor(category);
                      
                      SavedLink newLink = SavedLink(
                        title: title,
                        url: url,
                        category: category,
                        colorValue: color.value.toUnsigned(32),
                        createdAt: DateTime.now(),
                      );
                      
                      await _repository.addLink(newLink);
                      _loadLinks();
                      
                      setStateDialog(() {
                        _isLoading = false;
                      });
                      
                      if (context.mounted) {
                        Navigator.of(context).pop();  
                      }
                      _urlController.clear();
                    }
                  },
                  child: const Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteLink(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('링크 삭제'),
          content: const Text('이 링크를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _repository.deleteLink(savedLinks[index]);
                _loadLinks();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('삭제', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: savedLinks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.link_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '저장된 링크가 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+ 버튼을 눌러 새 링크를 추가해보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: savedLinks.length,
                itemBuilder: (context, index) {
                  final link = savedLinks[index];

                  return GestureDetector(
                    onTap: () {
                      String url = link.url;
                      if (!url.startsWith('http://') && !url.startsWith('https://')) {
                        url = 'https://$url';
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(url: url, title: link.title),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: Color(link.colorValue), size: 8),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    link.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    link.url, 
                                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Chip(
                                    label: Text(
                                      link.category,
                                      style: const TextStyle(fontSize: 12),
                                    ), 
                                    backgroundColor: Color(link.colorValue).withValues(alpha: 0.2),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteLink(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewLink,
        child: const Icon(Icons.add),
      ),
    );
  }
}