/// **SavedLink 도메인 엔터티**
/// 
/// 저장된 링크를 나타내는 도메인 엔터티로, 비즈니스 로직만 포함하고
/// 외부 프레임워크에 의존하지 않습니다.

import 'package:equatable/equatable.dart';

/// 링크 카테고리
enum LinkCategory {
  work('업무', '작업'),
  reference('참고자료', '참고'),
  learning('학습자료', '학습'),
  entertainment('엔터테인먼트', '오락'),
  shopping('쇼핑', '구매'),
  other('기타', '기타');

  const LinkCategory(this.displayName, this.keyword);
  final String displayName;
  final String keyword;

  static LinkCategory fromString(String? category) {
    if (category == null) return LinkCategory.other;
    
    switch (category.toLowerCase()) {
      case '업무':
      case 'work':
        return LinkCategory.work;
      case '참고자료':
      case 'reference':
        return LinkCategory.reference;
      case '학습자료':
      case 'learning':
        return LinkCategory.learning;
      case '엔터테인먼트':
      case 'entertainment':
        return LinkCategory.entertainment;
      case '쇼핑':
      case 'shopping':
        return LinkCategory.shopping;
      default:
        return LinkCategory.other;
    }
  }
}

/// SavedLink 도메인 엔터티
class SavedLinkEntity extends Equatable {
  final String id;
  final String url;
  final String title;
  final String description;
  final LinkCategory category;
  final DateTime createdAt;
  final DateTime? lastAccessedAt;
  final bool isFavorite;
  final List<String> tags;

  const SavedLinkEntity({
    required this.id,
    required this.url,
    required this.title,
    this.description = '',
    required this.category,
    required this.createdAt,
    this.lastAccessedAt,
    this.isFavorite = false,
    this.tags = const [],
  });

  /// URL 유효성 검증
  bool get isValidUrl {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 즐겨찾기 토글
  SavedLinkEntity toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }

  /// 최근 접근 시간 업데이트
  SavedLinkEntity markAccessed() {
    return copyWith(lastAccessedAt: DateTime.now());
  }

  /// 카테고리 변경
  SavedLinkEntity changeCategory(LinkCategory newCategory) {
    return copyWith(category: newCategory);
  }

  /// 태그 추가
  SavedLinkEntity addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// 태그 제거
  SavedLinkEntity removeTag(String tag) {
    if (!tags.contains(tag)) return this;
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  /// 도메인명 추출
  String get domain {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return '';
    }
  }

  /// 최근 접근 여부 (7일 이내)
  bool get isRecentlyAccessed {
    if (lastAccessedAt == null) return false;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return lastAccessedAt!.isAfter(weekAgo);
  }

  /// 복사본 생성 (불변성 보장)
  SavedLinkEntity copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    LinkCategory? category,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return SavedLinkEntity(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        url,
        title,
        description,
        category,
        createdAt,
        lastAccessedAt,
        isFavorite,
        tags,
      ];

  @override
  String toString() {
    return 'SavedLinkEntity(id: $id, title: $title, url: $url, '
           'category: $category, isFavorite: $isFavorite)';
  }
}