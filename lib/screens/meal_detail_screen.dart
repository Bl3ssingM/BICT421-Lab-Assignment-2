import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

/// Shows full details for a [Meal] received as a route argument.
///
/// Makes a second API call using the meal's [id] to retrieve the
/// full [MealDetail], demonstrating:
///   - Argument passing (receives [Meal] from [MealsListScreen])
///   - Async loading with loading/error/success states
///   - Deep navigation (3 levels: categories → meals → detail)
class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key, required this.meal});

  /// Summary meal passed from [MealsListScreen].
  final Meal meal;

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealService _service = MealService();
  late Future<MealDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _service.fetchMealDetail(widget.meal.id);
  }

  void _retry() {
    setState(() {
      _detailFuture = _service.fetchMealDetail(widget.meal.id);
    });
  }

  Future<void> _launchYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MealDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.meal.name)),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 56,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 12),
                    const Text('Failed to load meal details'),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: _retry, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          // Success
          final detail = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // ── Hero image app bar ──────────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    detail.name,
                    style: const TextStyle(
                        shadows: [Shadow(blurRadius: 4)]),
                  ),
                  background: Image.network(
                    detail.thumbnail,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Meta chips ────────────────────────────────────────
                    Wrap(
                      spacing: 8,
                      children: [
                        if (detail.category.isNotEmpty)
                          Chip(
                            avatar:
                                const Icon(Icons.restaurant_menu, size: 16),
                            label: Text(detail.category),
                          ),
                        if (detail.area.isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.public, size: 16),
                            label: Text(detail.area),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Ingredients ───────────────────────────────────────
                    Text('Ingredients',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                    const SizedBox(height: 8),
                    ...detail.ingredients.map(
                      (ing) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            const Icon(Icons.fiber_manual_record,
                                size: 8),
                            const SizedBox(width: 8),
                            Expanded(child: Text(ing)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Instructions ──────────────────────────────────────
                    Text('Instructions',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                    const SizedBox(height: 8),
                    Text(detail.instructions,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),

                    // ── YouTube button ────────────────────────────────────
                    if (detail.youtubeUrl.isNotEmpty)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Watch on YouTube'),
                        onPressed: () =>
                            _launchYoutube(detail.youtubeUrl),
                      ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}