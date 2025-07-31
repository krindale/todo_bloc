/// **Firebase 기반 원격 데이터 소스**
/// 
/// TodoRemoteDataSource 인터페이스의 Firebase Firestore 구현체입니다.
/// 원격 데이터베이스에 Todo 데이터를 동기화하고 관리합니다.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/app_logger.dart';
import '../models/todo_model.dart';
import 'todo_remote_datasource.dart';

class TodoFirebaseDataSource implements TodoRemoteDataSource {
  static const String _collectionName = 'todos';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> initialize() async {
    try {
      // Firebase 초기화는 main.dart에서 이미 완료됨
      AppLogger.info('Firebase TodoDataSource ready', tag: 'DataSource');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize Firebase TodoDataSource',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<TodoModel>> getAllTodos() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning('User not authenticated, returning empty list', tag: 'DataSource');
        return [];
      }

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: user.uid)
          .get();

      final todos = querySnapshot.docs
          .map((doc) => TodoModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      AppLogger.debug('Retrieved ${todos.length} todos from Firebase', tag: 'DataSource');
      return todos;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get all todos from Firebase',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<TodoModel?> getTodoById(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning('User not authenticated', tag: 'DataSource');
        return null;
      }

      final doc = await _firestore
          .collection(_collectionName)
          .doc(id)
          .get();

      if (doc.exists && doc.data()?['userId'] == user.uid) {
        final todo = TodoModel.fromJson({...doc.data()!, 'id': doc.id});
        AppLogger.debug('Retrieved todo with id: $id from Firebase', tag: 'DataSource');
        return todo;
      } else {
        AppLogger.debug('Todo with id: $id not found or unauthorized', tag: 'DataSource');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get todo by id: $id from Firebase',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> addTodo(TodoModel todo) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final todoData = todo.toJson();
      todoData['userId'] = user.uid;
      todoData['createdAt'] = FieldValue.serverTimestamp();
      todoData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collectionName)
          .doc(todo.id)
          .set(todoData);

      AppLogger.info('Added todo with id: ${todo.id} to Firebase', tag: 'DataSource');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to add todo with id: ${todo.id} to Firebase',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final todoData = todo.toJson();
      todoData['userId'] = user.uid;
      todoData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collectionName)
          .doc(todo.id)
          .update(todoData);

      AppLogger.info('Updated todo with id: ${todo.id} in Firebase', tag: 'DataSource');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update todo with id: ${todo.id} in Firebase',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 먼저 해당 todo가 현재 사용자의 것인지 확인
      final doc = await _firestore
          .collection(_collectionName)
          .doc(id)
          .get();

      if (doc.exists && doc.data()?['userId'] == user.uid) {
        await _firestore
            .collection(_collectionName)
            .doc(id)
            .delete();
        AppLogger.info('Deleted todo with id: $id from Firebase', tag: 'DataSource');
      } else {
        AppLogger.warning('Attempted to delete unauthorized or non-existent todo with id: $id', tag: 'DataSource');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete todo with id: $id from Firebase',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<TodoModel>> getTodosByCategory(String category) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning('User not authenticated, returning empty list', tag: 'DataSource');
        return [];
      }

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: user.uid)
          .where('category', isEqualTo: category)
          .get();

      final todos = querySnapshot.docs
          .map((doc) => TodoModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      AppLogger.debug('Retrieved ${todos.length} todos for category: $category from Firebase', tag: 'DataSource');
      return todos;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get todos by category: $category from Firebase',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<List<TodoModel>> getCompletedTodos() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning('User not authenticated, returning empty list', tag: 'DataSource');
        return [];
      }

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: user.uid)
          .where('isCompleted', isEqualTo: true)
          .get();

      final todos = querySnapshot.docs
          .map((doc) => TodoModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      AppLogger.debug('Retrieved ${todos.length} completed todos from Firebase', tag: 'DataSource');
      return todos;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get completed todos from Firebase',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<List<TodoModel>> getIncompleteTodos() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning('User not authenticated, returning empty list', tag: 'DataSource');
        return [];
      }

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: user.uid)
          .where('isCompleted', isEqualTo: false)
          .get();

      final todos = querySnapshot.docs
          .map((doc) => TodoModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      AppLogger.debug('Retrieved ${todos.length} incomplete todos from Firebase', tag: 'DataSource');
      return todos;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get incomplete todos from Firebase',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<void> clearAllTodos() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      AppLogger.info('Cleared all todos from Firebase', tag: 'DataSource');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to clear all todos from Firebase',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Stream<List<TodoModel>> watchAllTodos() {
    final user = _auth.currentUser;
    if (user == null) {
      AppLogger.warning('User not authenticated, returning empty stream', tag: 'DataSource');
      return Stream.value([]);
    }

    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((querySnapshot) {
      final todos = querySnapshot.docs
          .map((doc) => TodoModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      AppLogger.debug('Streaming ${todos.length} todos from Firebase', tag: 'DataSource');
      return todos;
    }).handleError((error, stackTrace) {
      AppLogger.error(
        'Error in Firebase todos stream',
        tag: 'DataSource',
        error: error,
        stackTrace: stackTrace,
      );
      return <TodoModel>[];
    });
  }

  @override
  Future<void> syncTodos(List<TodoModel> todos) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final batch = _firestore.batch();
      
      for (final todo in todos) {
        final todoData = todo.toJson();
        todoData['userId'] = user.uid;
        todoData['updatedAt'] = FieldValue.serverTimestamp();
        
        final docRef = _firestore.collection(_collectionName).doc(todo.id);
        batch.set(docRef, todoData, SetOptions(merge: true));
      }
      
      await batch.commit();
      AppLogger.info('Synced ${todos.length} todos to Firebase', tag: 'DataSource');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to sync todos to Firebase',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<TodoModel>> getTodosModifiedAfter(DateTime timestamp) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning('User not authenticated, returning empty list', tag: 'DataSource');
        return [];
      }

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: user.uid)
          .where('updatedAt', isGreaterThan: Timestamp.fromDate(timestamp))
          .get();

      final todos = querySnapshot.docs
          .map((doc) => TodoModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      AppLogger.debug('Retrieved ${todos.length} todos modified after $timestamp from Firebase', tag: 'DataSource');
      return todos;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get todos modified after $timestamp from Firebase',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<void> dispose() async {
    try {
      // Firebase는 앱 수준에서 관리되므로 특별한 정리가 필요하지 않음
      AppLogger.info('Firebase TodoDataSource disposed', tag: 'DataSource');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to dispose Firebase TodoDataSource',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}