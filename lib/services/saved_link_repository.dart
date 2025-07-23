import 'package:hive/hive.dart';
import '../model/saved_link.dart';

class SavedLinkRepository {
  static const String _boxName = 'saved_links';
  Box<SavedLink>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<SavedLink>(_boxName);
  }

  Future<void> addLink(SavedLink link) async {
    _ensureInitialized();
    await _box!.add(link);
  }

  List<SavedLink> getAllLinks() {
    _ensureInitialized();
    return _box!.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신순 정렬
  }

  Future<void> deleteLink(SavedLink link) async {
    _ensureInitialized();
    await link.delete();
  }

  Future<void> deleteLinkByKey(dynamic key) async {
    _ensureInitialized();
    await _box!.delete(key);
  }

  Future<void> updateLink(int index, SavedLink link) async {
    _ensureInitialized();
    await _box!.putAt(index, link);
  }

  Future<void> clear() async {
    _ensureInitialized();
    await _box!.clear();
  }

  int get length {
    _ensureInitialized();
    return _box!.length;
  }

  SavedLink? getAt(int index) {
    _ensureInitialized();
    return _box!.getAt(index);
  }

  void _ensureInitialized() {
    if (_box == null) {
      throw Exception('SavedLinkRepository가 초기화되지 않았습니다. init()을 먼저 호출하세요.');
    }
  }
}