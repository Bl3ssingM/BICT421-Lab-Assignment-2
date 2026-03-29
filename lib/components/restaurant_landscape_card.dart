import 'package:flutter/material.dart';

import '../models/restaurant.dart';

class RestaurantLandscapeCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;
  final bool recommended;

  const RestaurantLandscapeCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.apply(
      displayColor: theme.colorScheme.onSurface,
    );
    final borderRadius = BorderRadius.circular(recommended ? 16.0 : 12.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        elevation: recommended ? 10.0 : 2.0,
        shadowColor: recommended
            ? theme.colorScheme.primary.withAlpha((0.3 * 255).round())
            : Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: theme.colorScheme.primary.withAlpha(
            (0.16 * 255).round(),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'restaurant-${restaurant.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(recommended ? 16.0 : 12.0),
                      ),
                      child: AspectRatio(
                        aspectRatio: 2,
                        child: Image.asset(
                          restaurant.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(restaurant.name, style: textTheme.titleSmall),
                    subtitle: Text(
                      restaurant.attributes,
                      maxLines: 1,
                      style: textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                  ),
                ],
              ),
              if (recommended)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.secondary,
                          theme.colorScheme.primary,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12.0),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.recommend, size: 14.0, color: Colors.white),
                        SizedBox(width: 6.0),
                        Text(
                          'Recommended',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
