import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_bloc/util/todo_database.dart';
import 'package:todo_bloc/services/saved_link_repository.dart';
import 'package:todo_bloc/services/firebase_sync_service.dart';

class UserSessionService {
  static const String _lastUserIdKey = 'last_user_id';
  static const String _lastLoginTimeKey = 'last_login_time';
  
  static UserSessionService? _instance;
  static UserSessionService get instance {
    _instance ??= UserSessionService._();
    return _instance!;
  }
  
  UserSessionService._();
  
  /// 앱 시작 시 사용자 세션 확인 및 데이터 동기화
  Future<void> checkAndSyncUserSession() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      // 로그인하지 않은 상태
      await _clearAllLocalData();
      return;
    }
    
    final currentUserId = currentUser.uid;
    final lastUserId = await _getLastUserId();
    
    print('현재 사용자: $currentUserId');
    print('마지막 로그인 사용자: $lastUserId');
    
    if (lastUserId != currentUserId) {
      // 다른 사용자로 로그인한 경우
      print('사용자가 변경되었습니다. 로컬 데이터를 초기화하고 Firebase에서 동기화합니다.');
      await _handleUserChanged(currentUserId);
    } else {
      // 같은 사용자인 경우
      print('같은 사용자입니다. Firebase에서 최신 데이터를 동기화합니다.');
      await _syncFromFirebase();
    }
    
    // 현재 사용자 정보 저장
    await _saveCurrentUserInfo(currentUserId);
  }
  
  /// 사용자 변경 시 처리
  Future<void> _handleUserChanged(String newUserId) async {
    try {
      // 1. 로컬 데이터 완전 초기화
      await _clearAllLocalData();
      
      // 2. Firebase에서 새 사용자의 데이터 가져오기
      await _syncFromFirebase();
      
      print('사용자 변경 처리 완료: $newUserId');
    } catch (e) {
      print('사용자 변경 처리 중 오류 발생: $e');
      rethrow;
    }
  }
  
  /// Firebase에서 로컬 DB로 데이터 동기화
  Future<void> _syncFromFirebase() async {
    try {
      final syncService = FirebaseSyncService();
      
      if (syncService.isUserSignedIn) {
        print('Firebase에서 데이터 동기화 시작...');
        
        // Todo 데이터 동기화
        await syncService.syncTodosFromFirestore();
        
        // SavedLink 데이터 동기화
        await syncService.syncLinksFromFirestore();
        
        print('Firebase 데이터 동기화 완료');
      } else {
        print('사용자가 로그인하지 않아 동기화를 건너뜁니다.');
      }
    } catch (e) {
      print('Firebase 동기화 중 오류 발생: $e');
      // 동기화 실패해도 앱은 계속 실행되도록 함
    }
  }
  
  /// 모든 로컬 데이터 초기화
  Future<void> _clearAllLocalData() async {
    try {
      print('로컬 데이터 초기화 시작...');
      
      // TodoDatabase 초기화
      try {
        await TodoDatabase.clearUserData();
        print('Todo 데이터 초기화 완료');
      } catch (e) {
        print('Todo 데이터 초기화 실패: $e');
      }
      
      // SavedLinkRepository 초기화
      try {
        final savedLinkRepo = SavedLinkRepository();
        await savedLinkRepo.clearUserData();
        print('SavedLink 데이터 초기화 완료');
      } catch (e) {
        print('SavedLink 데이터 초기화 실패: $e');
      }
      
      print('로컬 데이터 초기화 완료');
    } catch (e) {
      print('로컬 데이터 초기화 중 오류 발생: $e');
    }
  }
  
  /// 마지막 로그인 사용자 ID 가져오기
  Future<String?> _getLastUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastUserIdKey);
    } catch (e) {
      print('마지막 사용자 ID 가져오기 실패: $e');
      return null;
    }
  }
  
  /// 현재 사용자 정보 저장
  Future<void> _saveCurrentUserInfo(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUserIdKey, userId);
      await prefs.setInt(_lastLoginTimeKey, DateTime.now().millisecondsSinceEpoch);
      print('사용자 정보 저장 완료: $userId');
    } catch (e) {
      print('사용자 정보 저장 실패: $e');
    }
  }
  
  /// 마지막 로그인 시간 가져오기
  Future<DateTime?> getLastLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastLoginTimeKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      print('마지막 로그인 시간 가져오기 실패: $e');
      return null;
    }
  }
  
  /// 로그아웃 시 호출 - 사용자 정보는 유지하고 다음 로그인을 위해 준비
  Future<void> onUserLogout() async {
    try {
      // 로그아웃 시에는 사용자 정보를 완전히 삭제하지 않고 유지
      // 다음에 같은 사용자가 로그인하면 데이터를 그대로 사용할 수 있도록
      print('사용자 로그아웃 처리');
    } catch (e) {
      print('로그아웃 처리 중 오류 발생: $e');
    }
  }
  
  /// 세션 정보 완전 초기화 (다른 계정으로 로그인할 준비)
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastUserIdKey);
      await prefs.remove(_lastLoginTimeKey);
      await _clearAllLocalData();
      print('세션 정보 완전 초기화 완료');
    } catch (e) {
      print('세션 초기화 중 오류 발생: $e');
    }
  }
}