import 'package:hive/hive.dart';

part 'saved_link.g.dart';

@HiveType(typeId: 1)
class SavedLink extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String url;

  @HiveField(2)
  String category;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  DateTime createdAt;

  SavedLink({
    required this.title,
    required this.url,
    required this.category,
    required this.colorValue,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'SavedLink{title: $title, url: $url, category: $category, colorValue: $colorValue, createdAt: $createdAt}';
  }
}