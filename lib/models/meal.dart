/// Summary meal returned by the filter endpoint.
/// Endpoint: https://www.themealdb.com/api/json/v1/1/filter.php?c=<Category>
class Meal {
  final String id;
  final String name;
  final String thumbnail;

  const Meal({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: json['strMealThumb'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'idMeal': id,
        'strMeal': name,
        'strMealThumb': thumbnail,
      };
}

/// Full meal detail returned by the lookup endpoint.
/// Endpoint: https://www.themealdb.com/api/json/v1/1/lookup.php?i=<id>
class MealDetail {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnail;
  final String youtubeUrl;
  final List<String> ingredients; // "measure ingredient" pairs

  const MealDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    required this.youtubeUrl,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    // TheMealDB stores up to 20 ingredient/measure pairs as numbered keys
    final ingredients = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient =
          (json['strIngredient$i'] as String?)?.trim() ?? '';
      final measure =
          (json['strMeasure$i'] as String?)?.trim() ?? '';
      if (ingredient.isNotEmpty) {
        ingredients.add(
          measure.isEmpty ? ingredient : '$measure $ingredient',
        );
      }
    }

    return MealDetail(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      category: (json['strCategory'] as String?) ?? '',
      area: (json['strArea'] as String?) ?? '',
      instructions: (json['strInstructions'] as String?) ?? '',
      thumbnail: (json['strMealThumb'] as String?) ?? '',
      youtubeUrl: (json['strYoutube'] as String?) ?? '',
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toJson() => {
        'idMeal': id,
        'strMeal': name,
        'strCategory': category,
        'strArea': area,
        'strInstructions': instructions,
        'strMealThumb': thumbnail,
        'strYoutube': youtubeUrl,
        // ingredients stored flat for simplicity
        'ingredients': ingredients,
      };
}