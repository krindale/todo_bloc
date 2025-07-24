import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo_item.dart';

class FirestoreTodoItem {
  static const String collectionName = 'todos';

  static Map<String, dynamic> toFirestore(TodoItem todo, String userId) {
    return {
      'title': todo.title,
      'priority': todo.priority,
      'dueDate': Timestamp.fromDate(todo.dueDate),
      'isCompleted': todo.isCompleted,
      'category': todo.category,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static TodoItem fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TodoItem(
      title: data['title'] ?? '',
      priority: data['priority'] ?? 'Medium',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      category: data['category'],
      firebaseDocId: doc.id, // Firebase 문서 ID 설정
    );
  }

  static Map<String, dynamic> updateFirestore(TodoItem todo) {
    return {
      'title': todo.title,
      'priority': todo.priority,
      'dueDate': Timestamp.fromDate(todo.dueDate),
      'isCompleted': todo.isCompleted,
      'category': todo.category,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}