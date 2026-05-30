import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  YoutubePlayerController? _youtubeController;

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

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  String? _extractYoutubeVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }

    if (uri.pathSegments.contains('embed') && uri.pathSegments.length > 1) {
      return uri.pathSegments[uri.pathSegments.indexOf('embed') + 1];
    }

    return null;
  }

  Widget _buildYoutubeEmbed(String url) {
    final videoId = _extractYoutubeVideoId(url);
    if (videoId == null || videoId.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_youtubeController == null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          forceHD: false,
        ),
      );
    } else if (_youtubeController!.metadata.videoId != videoId) {
      _youtubeController!.load(videoId);
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Theme.of(context).colorScheme.primary,
          progressColors: ProgressBarColors(
            playedColor: Theme.of(context).colorScheme.primary,
            handleColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
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

                    // ── Embedded YouTube player ────────────────────────────
                    if (detail.youtubeUrl.isNotEmpty) ...[
                      Text(
                        'Video',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildYoutubeEmbed(detail.youtubeUrl),
                    ],
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