import 'package:flutter/material.dart';
import '../models/food_category.dart';

class CategoryCard extends StatelessWidget {
  final FoodCategory category;
  final int restaurantCount;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.restaurantCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(
      context,
    ).textTheme.apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return InkWell(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8.0),
                  ),
                  child: Image.asset(category.imageUrl),
                ),
                Positioned(
                  left: 16.0,
                  top: 16.0,
                  child: Text('Yummy', style: textTheme.headlineLarge),
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text('Smoothies', style: textTheme.headlineLarge),
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text(category.name, style: textTheme.titleSmall),
              subtitle: Text(
                '$restaurantCount places',
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
