import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'components/post_card.dart';
import 'components/restaurant_landscape_card.dart';
import 'constants.dart';
import 'models/auth.dart';
import 'models/post.dart';
import 'models/restaurant.dart';
import 'providers/cart_provider.dart';
import 'providers/favourites_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/api_categories_screen.dart';

const double _zarConversionRate = 18.5;

String _formatZar(double amount) =>
    'R${(amount * _zarConversionRate).toStringAsFixed(2)}';

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
        Icon(Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.onSurface, size: 20.0),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(message,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
      ],
    ),
  );
}

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.auth,
    this.onCheckout,
    this.appTitle = 'Yummy',
  });

  final Auth auth;
  final VoidCallback? onCheckout; // ← simplified: no longer passes cartItems
  final String appTitle;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  // ── Cart actions — delegate to CartProvider ─────────────────────────────
  void _promptQuantityAndAddToCart(Item item) {
    int quantity = 1;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Select quantity',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8.0),
                  Text('Choose how many servings to add to your order.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          )),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: quantity > 1
                            ? () => setModalState(() => quantity--)
                            : null,
                      ),
                      const SizedBox(width: 16.0),
                      Text('$quantity',
                          style:
                              Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(width: 16.0),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setModalState(() => quantity++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<CartProvider>().add(item, quantity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        buildModernSnackBar(
                          context,
                          'Added x$quantity ${item.name} to cart',
                        ),
                      );
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

  // ── Favourites — delegate to FavouritesProvider ─────────────────────────
  void _toggleItemLike(Item item) {
    context.read<FavouritesProvider>().toggleItem(item);
    final liked = context.read<FavouritesProvider>().isItemLiked(item);
    ScaffoldMessenger.of(context).showSnackBar(
      buildModernSnackBar(
        context,
        liked
            ? 'Added "${item.name}" to liked items'
            : 'Removed "${item.name}" from liked items',
      ),
    );
  }

  void _toggleRestaurantLike(Restaurant restaurant) {
    context.read<FavouritesProvider>().toggleRestaurant(restaurant);
    final liked = context
        .read<FavouritesProvider>()
        .isRestaurantLiked(restaurant);
    ScaffoldMessenger.of(context).showSnackBar(
      buildModernSnackBar(
        context,
        liked
            ? 'Saved "${restaurant.name}" to favorites'
            : 'Removed "${restaurant.name}" from favorites',
      ),
    );
  }

  // ── Recommendations — reads from FavouritesProvider ─────────────────────
  List<Restaurant> _recommendedRestaurants(
      List<Restaurant> likedRestaurants) {
    final likedAttributes = likedRestaurants
        .expand((r) => r.attributes.split(','))
        .map((a) => a.trim().toLowerCase())
        .where((a) => a.isNotEmpty)
        .toSet();

    final allMatches = restaurants.where((r) {
      if (likedRestaurants.contains(r)) return false;
      if (likedAttributes.isEmpty) return true;
      final tags = r.attributes
          .split(',')
          .map((t) => t.trim().toLowerCase())
          .toSet();
      return tags.intersection(likedAttributes).isNotEmpty;
    }).toList();

    if (likedAttributes.isEmpty) {
      allMatches.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return allMatches.take(3).toList();
  }

  // ── Bottom sheets ────────────────────────────────────────────────────────
  void _showLikedItemsBottomSheet() {
    final likedItems =
        context.read<FavouritesProvider>().likedItems;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (_) => _ItemListSheet(
          title: 'Liked Items',
          items: likedItems,
          emptyMessage: 'No liked items yet.'),
    );
  }

  void _showLikedRestaurantsBottomSheet() {
    final likedRestaurants =
        context.read<FavouritesProvider>().likedRestaurants;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (_) => _RestaurantListSheet(
          title: 'Favorite Restaurants',
          restaurants: likedRestaurants,
          emptyMessage: 'No favorite restaurants yet.'),
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            // context.watch here so the sheet rebuilds when cart changes
            final cart = context.watch<CartProvider>();
            return _CartListSheet(
              cartItems: cart.items,
              scrollController: scrollController,
              onCheckout: widget.onCheckout == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      widget.onCheckout!();
                    },
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
          isRestaurantLiked: context
              .read<FavouritesProvider>()
              .isRestaurantLiked(restaurant),
          isItemLiked: (item) =>
              context.read<FavouritesProvider>().isItemLiked(item),
        ),
      ),
    );
  }

  // ── Header actions ───────────────────────────────────────────────────────
  Widget _buildHeaderActions(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    // Watch providers so badges update automatically
    final favs = context.watch<FavouritesProvider>();
    final cart = context.watch<CartProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Badge(
            label: Text('${favs.likedItemCount}'),
            child: const Icon(Icons.favorite_border),
          ),
          tooltip: 'Liked items',
          onPressed: _showLikedItemsBottomSheet,
        ),
        IconButton(
          icon: Badge(
            label: Text('${favs.likedRestaurantCount}'),
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
              child: Text('${cart.totalCount}',
                  key: ValueKey(cart.totalCount)),
            ),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          tooltip: 'Cart',
          onPressed: _showCartBottomSheet,
        ),
        PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'More actions',
          itemBuilder: (context) => [
            PopupMenuItem<int>(
              value: 0,
              child: ListTile(
                leading: Icon(isBright
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined),
                title: const Text('Toggle theme'),
              ),
            ),
            const PopupMenuDivider(),
            ...ColorSelection.values.map((cs) {
              final index = ColorSelection.values.indexOf(cs);
              return PopupMenuItem<int>(
                value: index + 1,
                enabled: cs != themeProvider.colorSelected,
                child: Row(
                  children: [
                    Icon(Icons.opacity_outlined, color: cs.color),
                    const SizedBox(width: 12.0),
                    Text(cs.label),
                  ],
                ),
              );
            }),
            const PopupMenuDivider(),
            PopupMenuItem<int>(
              value: -1,
              child: ListTile(
                leading: Icon(Icons.logout_rounded,
                    color: Theme.of(context).colorScheme.error),
                title: Text('Log out',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == -1) {
              final router = GoRouter.of(context);
              await widget.auth.signOut();
              if (!mounted) return;
              router.go('/login');
            } else if (value == 0) {
              context.read<ThemeProvider>().changeTheme(!isBright);
            } else {
              context.read<ThemeProvider>().changeColor(value - 1);
            }
          },
        ),
      ],
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Watch FavouritesProvider so restaurant tab recommendations update
    final likedRestaurants =
        context.watch<FavouritesProvider>().likedRestaurants;
    final recommended = _recommendedRestaurants(likedRestaurants);

    final pages = [
      // ── Tab 0: API-driven categories from TheMealDB ───────────────────
      const ApiCategoriesScreen(),

      // ── Tab 1: Posts (unchanged from Lab 2) ───────────────────────────
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

      // ── Tab 2: Restaurants (uses FavouritesProvider for recommended) ──
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            shrinkWrap: true,
            children: [
              if (recommended.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Text('Recommended for you',
                      style:
                          Theme.of(context).textTheme.headlineSmall),
                ),
                SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: recommended.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: 12.0),
                    itemBuilder: (context, index) {
                      final r = recommended[index];
                      return SizedBox(
                        width: 300,
                        child: RestaurantLandscapeCard(
                          restaurant: r,
                          recommended: true,
                          onTap: () => _openRestaurantDetail(r),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
              ...restaurants.map(
                (r) => RestaurantLandscapeCard(
                  restaurant: r,
                  onTap: () => _openRestaurantDetail(r),
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
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.category_outlined), text: 'Category'),
              Tab(icon: Icon(Icons.article_outlined), text: 'Post'),
              Tab(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  text: 'Restaurant'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}

// ── RestaurantDetailPage — unchanged logic, uses Provider via callbacks ───────

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;
  final void Function(Item) onBuyRequested;
  final void Function(Item) onItemLikeToggle;
  final void Function(Restaurant) onRestaurantLikeToggle;
  final bool isRestaurantLiked;
  final bool Function(Item) isItemLiked;

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
    setState(() => _restaurantLiked = !_restaurantLiked);
  }

  void _submitRating(int rating) {
    setState(() {
      _selectedRating = rating;
      _ratingSubmitted = true;
      widget.restaurant.rating =
          (widget.restaurant.rating + rating) / 2.0;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme =
        theme.textTheme.apply(displayColor: theme.colorScheme.onSurface);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        actions: [
          IconButton(
            icon: Icon(_restaurantLiked
                ? Icons.favorite
                : Icons.favorite_border),
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
              child: Image.asset(widget.restaurant.imageUrl,
                  fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(widget.restaurant.address, style: textTheme.bodyMedium),
          const SizedBox(height: 8.0),
          Text(widget.restaurant.getRatingAndDistance(),
              style: textTheme.bodySmall),
          const SizedBox(height: 16.0),
          Text('Rate this place', style: textTheme.titleMedium),
          const SizedBox(height: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                    value <= _selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 28),
                onPressed: () => _submitRating(value),
              );
            }),
          ),
          if (_ratingSubmitted)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Thanks! Your rating helps personalize recommendations.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.primary),
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
                      child: Image.asset(item.imageUrl,
                          width: 90, height: 90, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: textTheme.titleMedium),
                          const SizedBox(height: 6.0),
                          Text(item.description,
                              style: textTheme.bodySmall),
                          const SizedBox(height: 8.0),
                          Text(
                              'R${(item.price * _zarConversionRate).toStringAsFixed(2)}',
                              style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        // Watches FavouritesProvider for live badge updates
                        Consumer<FavouritesProvider>(
                          builder: (context, favs, _) => IconButton(
                            icon: Icon(
                                favs.isItemLiked(item)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.redAccent),
                            onPressed: () =>
                                widget.onItemLikeToggle(item),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              widget.onBuyRequested(item),
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
            Text('No reviews yet.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey.shade600))
          else
            ...widget.restaurant.reviews.take(3).map(
                  (review) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(review.reviewer,
                                style: textTheme.titleSmall),
                            const SizedBox(width: 8.0),
                            Text('${review.rating} ★',
                                style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.amber.shade700)),
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

// ── Sheet widgets — unchanged, cart now reads from CartProvider ───────────────

class _ItemListSheet extends StatelessWidget {
  const _ItemListSheet({
    required this.title,
    required this.items,
    required this.emptyMessage,
  });
  final String title;
  final List<Item> items;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12.0),
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(emptyMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey.shade600)),
              ),
            )
          else
            ...items.map(
              (item) => ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(item.imageUrl,
                      width: 52, height: 52, fit: BoxFit.cover),
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
  const _RestaurantListSheet({
    required this.title,
    required this.restaurants,
    required this.emptyMessage,
  });
  final String title;
  final List<Restaurant> restaurants;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12.0),
          if (restaurants.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(emptyMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey.shade600)),
              ),
            )
          else
            ...restaurants.map(
              (r) => ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(r.imageUrl,
                      width: 52, height: 52, fit: BoxFit.cover),
                ),
                title: Text(r.name),
                subtitle: Text(r.attributes),
              ),
            ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class _CartListSheet extends StatelessWidget {
  const _CartListSheet({
    required this.cartItems,
    this.scrollController,
    this.onCheckout,
  });

  final Map<Item, int> cartItems;
  final ScrollController? scrollController;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final entries = cartItems.entries.toList();
    final totalItems =
        entries.fold<int>(0, (sum, e) => sum + e.value);
    final totalPrice =
        entries.fold<double>(0.0, (sum, e) => sum + e.key.price * e.value);

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
            Text('Cart',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12.0),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text('Your cart is empty.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey.shade600)),
                ),
              )
            else ...[
              ...entries.map(
                (e) => ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(e.key.imageUrl,
                        width: 52, height: 52, fit: BoxFit.cover),
                  ),
                  title: Text(e.key.name),
                  subtitle: Text(
                      'x${e.value}  •  ${_formatZar(e.key.price * e.value)}'),
                  trailing: Text('Qty ${e.value}'),
                ),
              ),
              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text('$totalItems',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(_formatZar(totalPrice),
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                onPressed: onCheckout,
                child: const Text('Proceed to checkout'),
              ),
              const SizedBox(height: 8.0),
              Text('Estimated delivery: 15-20 min',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}