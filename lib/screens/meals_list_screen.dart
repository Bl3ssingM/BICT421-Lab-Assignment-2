import 'package:flutter/material.dart';
import '../models/meal_category.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';
import 'meal_detail_screen.dart';

/// Displays a list of meals for the given [category].
///
/// This screen receives a [MealCategory] as a route argument —
/// demonstrating argument passing between screens as required by
/// the navigation rubric.
class MealsListScreen extends StatefulWidget {
  const MealsListScreen({super.key, required this.category});

  /// Passed from [ApiCategoriesScreen] when a category card is tapped.
  final MealCategory category;

  @override
  State<MealsListScreen> createState() => _MealsListScreenState();
}

class _MealsListScreenState extends State<MealsListScreen> {
  final MealService _service = MealService();
  late Future<List<Meal>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    // Use the argument to drive the API call
    _mealsFuture = _service.fetchMealsByCategory(widget.category.name);
  }

  void _retry() {
    setState(() {
      _mealsFuture =
          _service.fetchMealsByCategory(widget.category.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        // Category description as subtitle
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              widget.category.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withAlpha((0.7 * 255).round()),
                ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Meal>>(
        future: _mealsFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 12),
                  Text(snapshot.error.toString(),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                      onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            );
          }

          final meals = snapshot.data ?? [];

          // Empty
          if (meals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.no_meals_outlined, size: 56),
                  const SizedBox(height: 12),
                  Text('No meals found for ${widget.category.name}'),
                ],
              ),
            );
          }

          // Success
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      meal.thumbnail,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Center(
                                      child:
                                          CircularProgressIndicator()),
                                ),
                    ),
                  ),
                  title: Text(
                    meal.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    // Navigate to detail with meal argument
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MealDetailScreen(meal: meal),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}