import 'package:flutter/material.dart';

import 'components/category_card.dart';
import 'components/post_card.dart';
import 'components/restaurant_landscape_card.dart';
import 'constants.dart';
import 'models/food_category.dart';
import 'models/post.dart';
import 'models/restaurant.dart';

const double _zarConversionRate = 18.5;

String _formatZar(double amount) {
  return 'R${(amount * _zarConversionRate).toStringAsFixed(2)}';
}

SnackBar buildModernSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
    elevation: 8.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
    backgroundColor: Theme.of(context).colorScheme.surface,
    duration: const Duration(seconds: 3),
    action: actionLabel != null && onAction != null
        ? SnackBarAction(
            label: actionLabel,
            onPressed: onAction,
            textColor: Theme.of(context).colorScheme.primary,
          )
        : null,
    content: Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).colorScheme.onSurface,
          size: 20.0,
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    ),
  );
}

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
    required this.appTitle,
  });

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;
  final String appTitle;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  FoodCategory? selectedCategory;
  final Map<Item, int> cartItems = {};
  final List<Item> likedItems = [];
  final List<Restaurant> likedRestaurants = [];
  final ScrollController _categoryScrollController = ScrollController();

  bool _isItemLiked(Item item) => likedItems.contains(item);

  int get _cartTotalCount => cartItems.values.fold(0, (sum, qty) => sum + qty);

  void _toggleItemLike(Item item) {
    setState(() {
      if (_isItemLiked(item)) {
        likedItems.remove(item);
      } else {
        likedItems.add(item);
      }
    });

    final message = _isItemLiked(item)
        ? 'Added "${item.name}" to liked items'
        : 'Removed "${item.name}" from liked items';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(buildModernSnackBar(context, message));
  }

  void _promptQuantityAndAddToCart(Item item) {
    int quantity = 1;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select quantity',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Choose how many servings to add to your order.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: quantity > 1
                            ? () => setState(() => quantity = quantity - 1)
                            : null,
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        '$quantity',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(width: 16.0),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () =>
                            setState(() => quantity = quantity + 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addItemToCart(item, quantity);
                    },
                    child: Text('Buy x$quantity'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addItemToCart(Item item, int quantity) {
    setState(() {
      cartItems[item] = (cartItems[item] ?? 0) + quantity;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      buildModernSnackBar(
        context,
        'Added x$quantity ${item.name} to cart',
        actionLabel: 'View cart',
        onAction: _showCartBottomSheet,
      ),
    );
  }

  List<Restaurant> _recommendedRestaurants() {
    final likedAttributes = likedRestaurants
        .expand((restaurant) => restaurant.attributes.split(','))
        .map((attribute) => attribute.trim().toLowerCase())
        .where((attribute) => attribute.isNotEmpty)
        .toSet();

    final allMatches = restaurants.where((restaurant) {
      if (likedRestaurants.contains(restaurant)) return false;
      if (likedAttributes.isEmpty) return true;
      final restaurantTags = restaurant.attributes
          .split(',')
          .map((tag) => tag.trim().toLowerCase())
          .toSet();
      return restaurantTags.intersection(likedAttributes).isNotEmpty;
    }).toList();

    if (likedAttributes.isEmpty) {
      allMatches.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return allMatches.take(3).toList();
  }

  void _toggleRestaurantLike(Restaurant restaurant) {
    setState(() {
      if (likedRestaurants.contains(restaurant)) {
        likedRestaurants.remove(restaurant);
      } else {
        likedRestaurants.add(restaurant);
      }
    });
    final message = likedRestaurants.contains(restaurant)
        ? 'Saved "${restaurant.name}" to favorites'
        : 'Removed "${restaurant.name}" from favorites';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(buildModernSnackBar(context, message));
  }

  void _showLikedItemsBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return _ItemListSheet(
          title: 'Liked Items',
          items: likedItems,
          emptyMessage: 'No liked items yet.',
        );
      },
    );
  }

  void _showLikedRestaurantsBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return _RestaurantListSheet(
          title: 'Favorite Restaurants',
          restaurants: likedRestaurants,
          emptyMessage: 'No favorite restaurants yet.',
        );
      },
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _CartListSheet(
              title: 'Cart',
              cartItems: cartItems,
              emptyMessage: 'Your cart is empty.',
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  void _openRestaurantDetail(Restaurant restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RestaurantDetailPage(
          restaurant: restaurant,
          onItemLikeToggle: _toggleItemLike,
          onBuyRequested: _promptQuantityAndAddToCart,
          onRestaurantLikeToggle: _toggleRestaurantLike,
          isRestaurantLiked: likedRestaurants.contains(restaurant),
          isItemLiked: _isItemLiked,
        ),
      ),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Badge(
            label: Text('${likedItems.length}'),
            child: const Icon(Icons.favorite_border),
          ),
          tooltip: 'Liked items',
          onPressed: _showLikedItemsBottomSheet,
        ),
        IconButton(
          icon: Badge(
            label: Text('${likedRestaurants.length}'),
            child: const Icon(Icons.restaurant),
          ),
          tooltip: 'Favorite restaurants',
          onPressed: _showLikedRestaurantsBottomSheet,
        ),
        IconButton(
          icon: Badge(
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Text('$_cartTotalCount', key: ValueKey(_cartTotalCount)),
            ),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          tooltip: 'Cart',
          onPressed: _showCartBottomSheet,
        ),
        PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'More actions',
          itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  leading: Icon(
                    isBright
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  title: const Text('Toggle theme'),
                ),
              ),
              const PopupMenuDivider(),
              ...ColorSelection.values.map((colorSelection) {
                final index = ColorSelection.values.indexOf(colorSelection);
                return PopupMenuItem<int>(
                  value: index + 1,
                  enabled: colorSelection != widget.colorSelected,
                  child: Row(
                    children: [
                      Icon(Icons.opacity_outlined, color: colorSelection.color),
                      const SizedBox(width: 12.0),
                      Text(colorSelection.label),
                    ],
                  ),
                );
              }),
            ];
          },
          onSelected: (value) {
            if (value == 0) {
              widget.changeTheme(!isBright);
            } else {
              widget.changeColor(value - 1);
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // Display all categories or restaurants for selected category
      selectedCategory == null
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: ListView.builder(
                  key: const PageStorageKey('categoryList'),
                  controller: _categoryScrollController,
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final count = restaurants
                        .where(
                          (r) => r.attributes.toLowerCase().contains(
                            category.name.toLowerCase(),
                          ),
                        )
                        .length;
                    return CategoryCard(
                      category: category,
                      restaurantCount: count,
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    );
                  },
                ),
              ),
            )
          : Builder(
              builder: (context) {
                final matchingRestaurants = restaurants
                    .where(
                      (r) => r.attributes.toLowerCase().contains(
                        selectedCategory!.name.toLowerCase(),
                      ),
                    )
                    .toList();
                return Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          selectedCategory = null;
                        });
                      },
                    ),
                    title: Text(selectedCategory!.name),
                    automaticallyImplyLeading: false,
                  ),
                  body: matchingRestaurants.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.hourglass_empty,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No places yet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Coming soon!',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView(
                          children: matchingRestaurants
                              .map(
                                (restaurant) => RestaurantLandscapeCard(
                                  restaurant: restaurant,
                                  onTap: () =>
                                      _openRestaurantDetail(restaurant),
                                ),
                              )
                              .toList(),
                        ),
                );
              },
            ),
      // Display all posts
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: posts.length,
            itemBuilder: (context, index) => PostCard(post: posts[index]),
          ),
        ),
      ),
      // Display all restaurants
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            shrinkWrap: true,
            children: [
              if (_recommendedRestaurants().isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Text(
                    'Recommended for you',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _recommendedRestaurants().length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12.0),
                    itemBuilder: (context, index) {
                      final restaurant = _recommendedRestaurants()[index];
                      return SizedBox(
                        width: 300,
                        child: RestaurantLandscapeCard(
                          restaurant: restaurant,
                          recommended: true,
                          onTap: () => _openRestaurantDetail(restaurant),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
              ...restaurants.map(
                (restaurant) => RestaurantLandscapeCard(
                  restaurant: restaurant,
                  onTap: () => _openRestaurantDetail(restaurant),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appTitle),
        elevation: 4.0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [_buildHeaderActions(context)],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutQuint,
        switchOutCurve: Curves.easeInQuint,
        child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (index) {
          setState(() {
            tab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Category',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Post',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Restaurant',
          ),
        ],
      ),
    );
  }
}

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;
  final void Function(Item item) onBuyRequested;
  final void Function(Item item) onItemLikeToggle;
  final void Function(Restaurant restaurant) onRestaurantLikeToggle;
  final bool isRestaurantLiked;
  final bool Function(Item item) isItemLiked;

  const RestaurantDetailPage({
    super.key,
    required this.restaurant,
    required this.onBuyRequested,
    required this.onItemLikeToggle,
    required this.onRestaurantLikeToggle,
    required this.isRestaurantLiked,
    required this.isItemLiked,
  });

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  late bool _restaurantLiked;
  int _selectedRating = 0;
  bool _ratingSubmitted = false;

  @override
  void initState() {
    super.initState();
    _restaurantLiked = widget.isRestaurantLiked;
  }

  void _toggleRestaurantLike() {
    widget.onRestaurantLikeToggle(widget.restaurant);
    setState(() {
      _restaurantLiked = !_restaurantLiked;
    });
  }

  void _submitRating(int rating) {
    setState(() {
      _selectedRating = rating;
      _ratingSubmitted = true;
      widget.restaurant.rating = (widget.restaurant.rating + rating) / 2.0;
      widget.restaurant.reviews.insert(
        0,
        Review(
          reviewer: 'You',
          rating: rating,
          comment: 'Delicious meal with great service — highly recommended!',
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      buildModernSnackBar(context, 'Thanks for rating $rating stars!'),
    );
  }

  void _toggleItemLike(Item item) {
    widget.onItemLikeToggle(item);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.apply(
      displayColor: theme.colorScheme.onSurface,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        actions: [
          IconButton(
            icon: Icon(
              _restaurantLiked ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: _toggleRestaurantLike,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Hero(
            tag: 'restaurant-${widget.restaurant.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(widget.restaurant.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(widget.restaurant.address, style: textTheme.bodyMedium),
          const SizedBox(height: 8.0),
          Text(
            widget.restaurant.getRatingAndDistance(),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rate this place', style: textTheme.titleMedium),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        final value = index + 1;
                        final currentRating = _selectedRating;
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            value <= currentRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 28,
                          ),
                          onPressed: () => _submitRating(value),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_ratingSubmitted)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Thanks! Your rating helps personalize recommendations.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          const SizedBox(height: 24.0),
          Text('Menu', style: textTheme.headlineSmall),
          const SizedBox(height: 12.0),
          ...widget.restaurant.items.map(
            (item) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        item.imageUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: textTheme.titleMedium),
                          const SizedBox(height: 6.0),
                          Text(item.description, style: textTheme.bodySmall),
                          const SizedBox(height: 8.0),
                          Text(
                            _formatZar(item.price),
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.isItemLiked(item)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _toggleItemLike(item),
                        ),
                        ElevatedButton(
                          onPressed: () => widget.onBuyRequested(item),
                          child: const Text('Buy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Reviews', style: textTheme.headlineSmall),
          const SizedBox(height: 12.0),
          if (widget.restaurant.reviews.isEmpty)
            Text(
              'No reviews yet. Tap a star to leave the first review.',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            )
          else
            ...widget.restaurant.reviews
                .take(3)
                .map(
                  (review) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(review.reviewer, style: textTheme.titleSmall),
                            const SizedBox(width: 8.0),
                            Text(
                              '${review.rating} ★',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        Text(review.comment, style: textTheme.bodySmall),
                        const Divider(height: 20.0),
                      ],
                    ),
                  ),
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ItemListSheet extends StatelessWidget {
  final String title;
  final List<Item> items;
  final String emptyMessage;

  const _ItemListSheet({
    required this.title,
    required this.items,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12.0),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...items.map(
              (item) => ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    item.imageUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(item.name),
                subtitle: Text(_formatZar(item.price)),
              ),
            ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class _RestaurantListSheet extends StatelessWidget {
  final String title;
  final List<Restaurant> restaurants;
  final String emptyMessage;

  const _RestaurantListSheet({
    required this.title,
    required this.restaurants,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12.0),
          if (restaurants.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...restaurants.map(
              (restaurant) => ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    restaurant.imageUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(restaurant.name),
                subtitle: Text(restaurant.attributes),
              ),
            ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class _CartListSheet extends StatelessWidget {
  final String title;
  final Map<Item, int> cartItems;
  final String emptyMessage;
  final ScrollController? scrollController;

  const _CartListSheet({
    required this.title,
    required this.cartItems,
    required this.emptyMessage,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final entries = cartItems.entries.toList();
    final totalItems = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    final totalPrice = entries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.key.price * entry.value,
    );

    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 24.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12.0),
            if (entries.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              ...entries.map(
                (entry) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      entry.key.imageUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(entry.key.name),
                  subtitle: Text(
                    'x${entry.value}  •  ${_formatZar(entry.key.price * entry.value)}',
                  ),
                  trailing: Text('Qty ${entry.value}'),
                ),
              ),
              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    '$totalItems',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    _formatZar(totalPrice),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    buildModernSnackBar(
                      context,
                      'Checkout isn\'t active yet, but your order is ready.',
                    ),
                  );
                },
                child: const Text('Proceed to checkout'),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Estimated delivery: 15-20 min',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
