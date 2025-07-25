import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/saved_link.dart';
import 'firebase_sync_service.dart';
import 'platform_strategy.dart';

class SavedLinkRepository {
  Box<SavedLink>? _box;
  final _syncService = FirebaseSyncService();
  late final PlatformStrategy _platformStrategy;

  SavedLinkRepository() {
    _platformStrategy = PlatformStrategyFactory.create();
  }

  // 플랫폼별 데이터 소스 결정
  bool _shouldUseFirebaseOnly() {
    return _platformStrategy.shouldUseFirebaseOnly();
  }

  // 사용자별 박스명 생성
  String _getBoxName() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    return 'saved_links_$userId';
  }

  Future<void> init() async {
    try {
      print('SavedLinkRepository: Initializing...');
      print('SavedLinkRepository: Platform: ${_platformStrategy.strategyName}');
      
      if (_shouldUseFirebaseOnly()) {
        print('SavedLinkRepository: Firebase-only platform, skipping Hive init');
        return; // Firebase-only 플랫폼에서는 로컬 DB 초기화 불필요
      }
      
      final boxName = _getBoxName();
      print('SavedLinkRepository: Opening Hive box: $boxName');
      _box = await Hive.openBox<SavedLink>(boxName);
      print('SavedLinkRepository: Hive box opened successfully');
    } catch (e) {
      print('SavedLinkRepository: Error during init: $e');
      rethrow;
    }
  }

  Future<void> addLink(SavedLink link) async {
    if (_shouldUseFirebaseOnly()) {
      // Firebase에만 저장
      final docId = await _syncService.addLinkToFirestore(link);
      if (docId != null) {
        link.firebaseDocId = docId;
      }
      return;
    }
    
    _ensureInitialized();
    try {
      // 1. Firebase에 먼저 저장하고 문서 ID 받기
      final docId = await _syncService.addLinkToFirestore(link);
      
      // 2. Firebase 문서 ID를 할당
      if (docId != null) {
        link.firebaseDocId = docId;
      }
      
      // 3. 로컬 Hive에 저장
      await _box!.add(link);
    } catch (e) {
      print('SavedLink 추가 중 오류: $e');
      // Firebase 실패해도 로컬에는 저장
      await _box!.add(link);
    }
  }

  Future<List<SavedLink>> getAllLinks() async {
    try {
      print('SavedLinkRepository: Getting all links...');
      print('SavedLinkRepository: Should use Firebase only: ${_shouldUseFirebaseOnly()}');
      
      if (_shouldUseFirebaseOnly()) {
        print('SavedLinkRepository: Loading from Firebase...');
        // Firebase에서 직접 데이터 가져오기
        final snapshot = await _syncService.savedLinksStream().first;
        print('SavedLinkRepository: Firebase returned ${snapshot.length} links');
        return snapshot;
      }
      
      print('SavedLinkRepository: Loading from local Hive...');
      _ensureInitialized();
      final localLinks = _box!.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신순 정렬
      print('SavedLinkRepository: Local Hive returned ${localLinks.length} links');
      return localLinks;
    } catch (e) {
      print('SavedLinkRepository: Error in getAllLinks: $e');
      return [];
    }
  }

  Future<void> deleteLink(SavedLink link) async {
    if (_shouldUseFirebaseOnly()) {
      // Firebase에서만 삭제
      if (link.firebaseDocId != null) {
        await _syncService.deleteLinkFromFirestore(link.firebaseDocId!);
      }
      return;
    }
    
    _ensureInitialized();
    try {
      // 1. Firebase에서 삭제
      if (link.firebaseDocId != null) {
        await _syncService.deleteLinkFromFirestore(link.firebaseDocId!);
      }
      
      // 2. 로컬에서 삭제
      await link.delete();
    } catch (e) {
      print('SavedLink 삭제 중 오류: $e');
      // Firebase 실패해도 로컬은 삭제
      await link.delete();
    }
  }

  Future<void> deleteLinkByKey(dynamic key) async {
    if (_shouldUseFirebaseOnly()) {
      throw Exception('Key-based deletion not supported on Firebase-only platforms');
    }
    
    _ensureInitialized();
    await _box!.delete(key);
  }

  Future<void> updateLink(int index, SavedLink link) async {
    if (_shouldUseFirebaseOnly()) {
      // Firebase에서만 업데이트
      await _syncService.updateLinkInFirestore(link);
      return;
    }
    
    _ensureInitialized();
    try {
      // 1. Firebase에서 업데이트
      await _syncService.updateLinkInFirestore(link);
      
      // 2. 로컬 Hive에서 업데이트
      await _box!.putAt(index, link);
    } catch (e) {
      print('SavedLink 업데이트 중 오류: $e');
      // Firebase 실패해도 로컬은 업데이트
      await _box!.putAt(index, link);
    }
  }

  Future<void> clear() async {
    if (_shouldUseFirebaseOnly()) {
      return; // Firebase-only 플랫폼에서는 아무것도 하지 않음
    }
    
    _ensureInitialized();
    await _box!.clear();
  }

  // ✅ 로그아웃 시 사용자 데이터 완전 삭제
  Future<void> clearUserData() async {
    if (_shouldUseFirebaseOnly()) {
      return; // Firebase-only 플랫폼에서는 로컬 데이터가 없으므로 아무것도 하지 않음
    }
    
    try {
      if (_box != null) {
        await _box!.clear();
        await _box!.close();
        _box = null;
      }
      await Hive.deleteBoxFromDisk(_getBoxName());
    } catch (e) {
      print('사용자 SavedLink 데이터 삭제 중 오류: $e');
    }
  }

  Future<int> get length async {
    if (_shouldUseFirebaseOnly()) {
      final links = await getAllLinks();
      return links.length;
    }
    
    _ensureInitialized();
    return _box!.length;
  }

  Future<SavedLink?> getAt(int index) async {
    if (_shouldUseFirebaseOnly()) {
      final links = await getAllLinks();
      return index < links.length ? links[index] : null;
    }
    
    _ensureInitialized();
    return _box!.getAt(index);
  }

  void _ensureInitialized() {
    if (!_shouldUseFirebaseOnly() && _box == null) {
      throw Exception('SavedLinkRepository가 초기화되지 않았습니다. init()을 먼저 호출하세요.');
    }
  }
}