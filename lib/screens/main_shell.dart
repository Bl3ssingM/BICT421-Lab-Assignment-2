import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../home.dart';
import '../models/auth.dart';
import '../providers/cart_provider.dart';
import 'account_page.dart';
import 'orders_page.dart';
import 'payment_methods_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.auth});

  final Auth auth;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final List<PlacedOrder> _orders = [];

  /// Called when the user taps "Proceed to checkout" in the cart.
  /// Reads cart data from [CartProvider] instead of receiving it as a callback.
  void _onCheckout() {
    final cartProvider = context.read<CartProvider>();
    if (cartProvider.isEmpty) return;

    setState(() {
      _orders.add(PlacedOrder(
        items: Map.from(cartProvider.items),
        placedAt: DateTime.now(),
        total: cartProvider.totalPriceUsd,
      ));
      _selectedIndex = 1; // switch to Orders tab
    });

    cartProvider.clear(); // clear cart after placing order
  }

  void _goToPaymentMethods() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PaymentMethodsPage(),
      ),
    );
  }

  void _onAddMore() => setState(() => _selectedIndex = 0);

  void _onCancelOrder(int index) {
    setState(() {
      if (index >= 0 && index < _orders.length) {
        _orders.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      Home(auth: widget.auth, onCheckout: _onCheckout),
      OrdersPage(
        orders: _orders,
        onGoToPaymentMethods: _goToPaymentMethods,
        onCancelOrder: _onCancelOrder,
        onAddMore: _onAddMore,
      ),
      AccountPage(
        auth: widget.auth,
        onLogOut: () async {
          final router = GoRouter.of(context);
          await widget.auth.signOut();
          if (!mounted) return;
          router.go('/login');
        },
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