import 'package:flutter/material.dart';
import '../components/category_card.dart';
import '../models/food_category.dart';
import '../models/meal_category.dart';
import '../services/meal_service.dart';
import 'meals_list_screen.dart';

/// Fetches food categories from TheMealDB and renders them using
/// the existing [CategoryCard] component from Lab Assignment 2.
///
/// This demonstrates direct continuity with Lab 2 — the same card
/// widget now renders API-driven data instead of hard-coded assets.
///
/// Demonstrates all four required data states:
///   1. Loading  — spinner while the HTTP request is in flight
///   2. Success  — grid of [CategoryCard] widgets (Lab 2 component)
///   3. Empty    — friendly message when the API returns no data
///   4. Error    — retry button with the error message displayed
class ApiCategoriesScreen extends StatefulWidget {
  const ApiCategoriesScreen({super.key});

  @override
  State<ApiCategoriesScreen> createState() => _ApiCategoriesScreenState();
}

class _ApiCategoriesScreenState extends State<ApiCategoriesScreen> {
  final MealService _service = MealService();
  late Future<List<MealCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _service.fetchCategories();
  }

  void _retry() {
    setState(() {
      _categoriesFuture = _service.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MealCategory>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        // ── 1. Loading state ──────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading categories…'),
              ],
            ),
          );
        }

        // ── 4. Error state ────────────────────────────────────────────────
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load categories',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: _retry,
                  ),
                ],
              ),
            ),
          );
        }

        final categories = snapshot.data ?? [];

        // ── 3. Empty state ────────────────────────────────────────────────
        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_meals_outlined,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text('No categories found.'),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: _retry, child: const Text('Retry')),
              ],
            ),
          );
        }

        // ── 2. Success state — uses Lab 2's CategoryCard ──────────────────
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final mealCategory = categories[index];

            // Adapt MealCategory → FoodCategory so CategoryCard (Lab 2)
            // can render it. The thumbnail is a network URL — CategoryCard
            // now detects this and uses Image.network automatically.
            final adapted = FoodCategory(
              mealCategory.name,
              0,               // count not provided by TheMealDB filter endpoint
              mealCategory.thumbnail, // network URL from API
            );

            return CategoryCard(
              category: adapted,
              restaurantCount: 0,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        MealsListScreen(category: mealCategory),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}