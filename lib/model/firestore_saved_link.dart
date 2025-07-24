import 'package:cloud_firestore/cloud_firestore.dart';
import 'saved_link.dart';

class FirestoreSavedLink {
  static const String collectionName = 'saved_links';

  static Map<String, dynamic> toFirestore(SavedLink link, String userId) {
    return {
      'title': link.title,
      'url': link.url,
      'category': link.category,
      'colorValue': link.colorValue,
      'createdAt': Timestamp.fromDate(link.createdAt),
      'userId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static SavedLink fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedLink(
      title: data['title'] ?? '',
      url: data['url'] ?? '',
      category: data['category'] ?? '',
      colorValue: data['colorValue'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      firebaseDocId: doc.id, // Firebase 문서 ID 설정
    );
  }

  static Map<String, dynamic> updateFirestore(SavedLink link) {
    return {
      'title': link.title,
      'url': link.url,
      'category': link.category,
      'colorValue': link.colorValue,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}