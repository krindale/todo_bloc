/// **SavedLink 도메인 레포지토리 인터페이스**
/// 
/// 저장된 링크 관리를 위한 도메인 레포지토리 인터페이스입니다.

import '../entities/saved_link_entity.dart';

/// SavedLink 레포지토리 인터페이스
abstract class SavedLinkRepository {
  /// 모든 저장된 링크 조회
  Future<List<SavedLinkEntity>> getAllLinks();

  /// ID로 특정 링크 조회
  Future<SavedLinkEntity?> getLinkById(String id);

  /// 즐겨찾기 링크들 조회
  Future<List<SavedLinkEntity>> getFavoriteLinks();

  /// 카테고리별 링크들 조회
  Future<List<SavedLinkEntity>> getLinksByCategory(LinkCategory category);

  /// 최근 접근한 링크들 조회
  Future<List<SavedLinkEntity>> getRecentlyAccessedLinks();

  /// 링크 추가
  Future<String> addLink(SavedLinkEntity link);

  /// 링크 수정
  Future<void> updateLink(SavedLinkEntity link);

  /// 링크 삭제
  Future<void> deleteLink(String id);

  /// 여러 링크 삭제
  Future<void> deleteLinks(List<String> ids);

  /// 즐겨찾기 토글
  Future<void> toggleFavorite(String id);

  /// 링크 접근 기록
  Future<void> markAsAccessed(String id);

  /// 링크 검색
  Future<List<SavedLinkEntity>> searchLinks(String query);

  /// 태그로 링크 검색
  Future<List<SavedLinkEntity>> getLinksByTag(String tag);

  /// 모든 태그 조회
  Future<List<String>> getAllTags();

  /// 링크 실시간 스트림 (선택적)
  Stream<List<SavedLinkEntity>>? getLinksStream();
}