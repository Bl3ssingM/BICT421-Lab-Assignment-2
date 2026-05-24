/// Model for a food category returned by TheMealDB API.
/// Endpoint: https://www.themealdb.com/api/json/v1/1/categories.php
class MealCategory {
  final String id;
  final String name;
  final String thumbnail;
  final String description;

  const MealCategory({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.description,
  });

  // ── JSON deserialization ────────────────────────────────────────────────────
  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id: json['idCategory'] as String,
      name: json['strCategory'] as String,
      thumbnail: json['strCategoryThumb'] as String,
      description: (json['strCategoryDescription'] as String?) ?? '',
    );
  }

  // ── JSON serialization ──────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'idCategory': id,
        'strCategory': name,
        'strCategoryThumb': thumbnail,
        'strCategoryDescription': description,
      };

  @override
  String toString() => 'MealCategory(id: $id, name: $name)';
}