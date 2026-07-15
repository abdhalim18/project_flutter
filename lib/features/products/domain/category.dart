import '../../../core/db/app_database.dart' show CategoryRow;

class Category {
  const Category({required this.id, required this.name});

  final String id;
  final String name;

  factory Category.fromRow(CategoryRow row) {
    return Category(id: row.id, name: row.name);
  }
}
