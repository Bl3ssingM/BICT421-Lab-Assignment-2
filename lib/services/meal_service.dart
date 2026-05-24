import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_category.dart';
import '../models/meal.dart';

/// Handles all HTTP communication with TheMealDB REST API.
/// Base URL: https://www.themealdb.com/api/json/v1/1/
///
/// No API key is required — the public endpoint is used throughout.
class MealService {
  static const String _baseUrl =
      'https://www.themealdb.com/api/json/v1/1';

  final http.Client _client;

  /// Allows injecting a mock client for testing.
  MealService({http.Client? client}) : _client = client ?? http.Client();

  // ── Fetch all food categories ─────────────────────────────────────────────

  /// Returns a list of [MealCategory] objects parsed from the API.
  /// Throws an [Exception] on non-200 responses or malformed JSON.
  Future<List<MealCategory>> fetchCategories() async {
    final uri = Uri.parse('$_baseUrl/categories.php');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> rawList = body['categories'] as List<dynamic>;
      return rawList
          .map((e) => MealCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      'Failed to load categories — HTTP ${response.statusCode}',
    );
  }

  // ── Fetch meals by category ───────────────────────────────────────────────

  /// Returns summary [Meal] objects for the given [categoryName].
  Future<List<Meal>> fetchMealsByCategory(String categoryName) async {
    final uri = Uri.parse(
      '$_baseUrl/filter.php?c=${Uri.encodeComponent(categoryName)}',
    );
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final rawList = body['meals'] as List<dynamic>?;

      // API returns null for empty categories
      if (rawList == null) return [];

      return rawList
          .map((e) => Meal.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      'Failed to load meals for "$categoryName" — HTTP ${response.statusCode}',
    );
  }

  // ── Fetch full meal detail ────────────────────────────────────────────────

  /// Returns a single [MealDetail] for the given [mealId].
  Future<MealDetail> fetchMealDetail(String mealId) async {
    final uri = Uri.parse('$_baseUrl/lookup.php?i=$mealId');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final rawList = body['meals'] as List<dynamic>?;

      if (rawList == null || rawList.isEmpty) {
        throw Exception('Meal $mealId not found');
      }

      return MealDetail.fromJson(rawList.first as Map<String, dynamic>);
    }

    throw Exception(
      'Failed to load meal detail — HTTP ${response.statusCode}',
    );
  }
}