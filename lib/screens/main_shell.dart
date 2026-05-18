import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../home.dart';
import '../models/auth.dart';
import '../models/restaurant.dart';
import 'account_page.dart';
import 'orders_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.auth,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });

  final Auth auth;
  final void Function(bool) changeTheme;
  final void Function(int) changeColor;
  final ColorSelection colorSelected;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final List<PlacedOrder> _orders = [];

  // Called from the cart sheet when user taps "Proceed to checkout"
  void _onCheckout(Map<Item, int> cartItems) {
    if (cartItems.isEmpty) return;
    final total = cartItems.entries
        .fold(0.0, (sum, e) => sum + e.key.price * e.value);
    setState(() {
      _orders.add(PlacedOrder(
        items: Map.from(cartItems),
        placedAt: DateTime.now(),
        total: total,
      ));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _selectedIndex = 1); // switch to Orders tab automatically
    });
  }

  void _cancelOrder(int index) {
    if (index < 0 || index >= _orders.length) return;
    setState(() {
      _orders.removeAt(index);
    });
  }

  void _onAddMore() {
    setState(() => _selectedIndex = 0);
  }

  void _goToAccount() {
    setState(() => _selectedIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      // ── Explore ──────────────────────────────────────────────────────────
      Home(
        auth: widget.auth,
        changeTheme: widget.changeTheme,
        changeColor: widget.changeColor,
        colorSelected: widget.colorSelected,
        onCheckout: _onCheckout,
      ),
      // ── Orders ───────────────────────────────────────────────────────────
      OrdersPage(
        orders: _orders,
        onGoToAccount: _goToAccount,
        onCancelOrder: _cancelOrder,
        onAddMore: _onAddMore,
      ),
      // ── Account ──────────────────────────────────────────────────────────
      AccountPage(
        auth: widget.auth,
        onLogOut: () {
          widget.auth.signOut().then((_) => context.go('/login'));
        },
        onGoToOrders: () => setState(() => _selectedIndex = 1),
        changeTheme: widget.changeTheme,
        changeColor: widget.changeColor,
        colorSelected: widget.colorSelected,
      ),
    ];

    return Scaffold(
      body: tabs[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}