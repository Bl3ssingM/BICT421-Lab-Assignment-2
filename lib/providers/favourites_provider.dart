import 'package:flutter/material.dart';
import '../models/restaurant.dart';

/// Manages liked items and favourite restaurants across the application.
///
/// Widgets subscribe with `context.watch<FavouritesProvider>()` so they
/// rebuild automatically whenever favourites change — this is the key
/// advantage over passing callback props through widget constructors.
class FavouritesProvider extends ChangeNotifier {
  final List<Item> _likedItems = [];
  final List<Restaurant> _likedRestaurants = [];

  // ── Read-only views ────────────────────────────────────────────────────────

  List<Item> get likedItems => List.unmodifiable(_likedItems);
  List<Restaurant> get likedRestaurants =>
      List.unmodifiable(_likedRestaurants);

  int get likedItemCount => _likedItems.length;
  int get likedRestaurantCount => _likedRestaurants.length;

  bool isItemLiked(Item item) => _likedItems.contains(item);
  bool isRestaurantLiked(Restaurant restaurant) =>
      _likedRestaurants.contains(restaurant);

  // ── Mutations ──────────────────────────────────────────────────────────────

  /// Toggles the liked state of [item] and notifies all listeners.
  void toggleItem(Item item) {
    if (_likedItems.contains(item)) {
      _likedItems.remove(item);
    } else {
      _likedItems.add(item);
    }
    notifyListeners();
  }

  /// Toggles the liked state of [restaurant] and notifies all listeners.
  void toggleRestaurant(Restaurant restaurant) {
    if (_likedRestaurants.contains(restaurant)) {
      _likedRestaurants.remove(restaurant);
    } else {
      _likedRestaurants.add(restaurant);
    }
    notifyListeners();
  }
}