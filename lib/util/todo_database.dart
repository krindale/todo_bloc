/// **Todo 데이터베이스 유틸리티**
/// 
/// Hive 로컬 데이터베이스와 Firebase Firestore 간의 플랫폼별 데이터 액세스를 
/// 추상화하는 유틸리티 클래스입니다. 플랫폼에 따라 최적의 데이터 저장 방식을 선택합니다.
/// 
/// **플랫폼별 전략:**
/// - **모바일 (Android/iOS)**: Hive 로컬 DB + Firebase 동기화
/// - **데스크톱 (Windows/macOS)**: Firebase 직접 사용
/// - **웹**: Firebase Firestore 전용
/// 
/// **주요 기능:**
/// - 플랫폼 자동 감지 및 적절한 데이터소스 선택
/// - Hive 박스 초기화 및 관리
/// - Firebase 동기화 트리거
/// - 데이터 CRUD 작업 추상화
/// 
/// **설계 패턴:**
/// - Strategy 패턴: 플랫폼별 데이터 접근 방식
/// - Facade 패턴: 복잡한 데이터 계층 단순화
/// - Singleton 패턴: 전역 데이터베이스 인스턴스
/// 
/// **성능 최적화:**
/// - 로컬 우선 접근 (오프라인 지원)
/// - 백그라운드 동기화
/// - 플랫폼별 최적화된 저장 방식

import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../model/todo_item.dart';
import '../services/firebase_sync_service.dart';

class TodoDatabase {
  static final _syncService = FirebaseSyncService();

  // 플랫폼별 데이터 소스 결정
  static bool _shouldUseFirebaseOnly() {
    return kIsWeb || 
           Platform.isMacOS || 
           Platform.isWindows;
  }

  // 사용자별 박스명 생성
  static String _getBoxName() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    return "todoBox_$userId";
  }

  static Future<Box<TodoItem>> getBox() async {
    if (_shouldUseFirebaseOnly()) {
      throw Exception('Local database not supported on this platform');
    }
    return await Hive.openBox<TodoItem>(_getBoxName());
  }

  // ✅ 모든 할 일 가져오기 (Read All)
  static Future<List<TodoItem>> getTodos() async {
    if (_shouldUseFirebaseOnly()) {
      // Firebase에서 직접 데이터 가져오기
      final snapshot = await _syncService.todosStream().first;
      return snapshot;
    }
    
    final box = await Hive.openBox<TodoItem>(_getBoxName());
    return box.values.toList();
  }

  // ✅ 새로운 할 일 추가 (Firebase 동시 저장)
  static Future<void> addTodo(TodoItem todo) async {
    if (_shouldUseFirebaseOnly()) {
      // Firebase에만 저장
      final docId = await _syncService.addTodoToFirestore(todo);
      if (docId != null) {
        todo.firebaseDocId = docId;
      }
      return;
    }
    
    try {
      // 1. Firebase에 먼저 저장하고 문서 ID 받기
      final docId = await _syncService.addTodoToFirestore(todo);
      
      // 2. Firebase 문서 ID를 할당
      if (docId != null) {
        todo.firebaseDocId = docId;
      }
      
      // 3. 로컬 Hive에 저장
      final box = await Hive.openBox<TodoItem>(_getBoxName());
      await box.add(todo);
    } catch (e) {
      print('Todo 추가 중 오류: $e');
      // Firebase 실패해도 로컬에는 저장
      final box = await Hive.openBox<TodoItem>(_getBoxName());
      await box.add(todo);
    }
  }

  // ✅ 특정 할 일 업데이트 (Firebase 동시 수정)
  static Future<void> updateTodo(int index, TodoItem updatedTodo) async {
    if (_shouldUseFirebaseOnly()) {
      // Firebase에서만 업데이트
      await _syncService.updateTodoInFirestore(updatedTodo);
      return;
    }
    
    try {
      // 1. Firebase에서 업데이트
      await _syncService.updateTodoInFirestore(updatedTodo);
      
      // 2. 로컬 Hive에서 업데이트
      final box = await Hive.openBox<TodoItem>(_getBoxName());
      await box.putAt(index, updatedTodo);
    } catch (e) {
      print('Todo 업데이트 중 오류: $e');
      // Firebase 실패해도 로컬은 업데이트
      final box = await Hive.openBox<TodoItem>(_getBoxName());
      await box.putAt(index, updatedTodo);
    }
  }

  // ✅ 특정 할 일 삭제 (Firebase 동시 삭제)
  static Future<void> deleteTodo(int index) async {
    if (_shouldUseFirebaseOnly()) {
      throw Exception('Index-based deletion not supported on Firebase-only platforms. Use deleteTodoByItem() instead.');
    }
    
    try {
      final box = await Hive.openBox<TodoItem>(_getBoxName());
      
      // 1. 삭제할 아이템의 Firebase 문서 ID 가져오기
      final todoToDelete = box.getAt(index);
      
      // 2. Firebase에서 삭제
      if (todoToDelete?.firebaseDocId != null) {
        await _syncService.deleteTodoFromFirestore(todoToDelete!.firebaseDocId!);
      }
      
      // 3. 로컬에서 삭제
      await box.deleteAt(index);
    } catch (e) {
      print('Todo 삭제 중 오류: $e');
      // Firebase 실패해도 로컬은 삭제
      final box = await Hive.openBox<TodoItem>(_getBoxName());
      await box.deleteAt(index);
    }
  }

  // ✅ TodoItem으로 삭제 (Firebase-only 플랫폼용)
  static Future<void> deleteTodoByItem(TodoItem todo) async {
    if (_shouldUseFirebaseOnly()) {
      // Firebase에서만 삭제
      if (todo.firebaseDocId != null) {
        await _syncService.deleteTodoFromFirestore(todo.firebaseDocId!);
      }
      return;
    }
    
    // 로컬 DB에서는 기존 방식 사용
    final todos = await getTodos();
    final index = todos.indexWhere((t) => 
        t.firebaseDocId == todo.firebaseDocId && 
        t.firebaseDocId != null);
    if (index != -1) {
      await deleteTodo(index);
    }
  }

  // ✅ 모든 할 일 삭제 (Firebase 동기화용)
  static Future<void> clearAll() async {
    if (_shouldUseFirebaseOnly()) {
      return; // Firebase-only 플랫폼에서는 아무것도 하지 않음
    }
    
    final box = await Hive.openBox<TodoItem>(_getBoxName());
    await box.clear();
  }

  // ✅ 로그아웃 시 사용자 데이터 완전 삭제
  static Future<void> clearUserData() async {
    if (_shouldUseFirebaseOnly()) {
      return; // Firebase-only 플랫폼에서는 로컬 데이터가 없으므로 아무것도 하지 않음
    }
    
    try {
      final box = await Hive.openBox<TodoItem>(_getBoxName());
      await box.clear();
      await box.close();
      await Hive.deleteBoxFromDisk(_getBoxName());
    } catch (e) {
      print('사용자 Todo 데이터 삭제 중 오류: $e');
    }
  }
}
