import 'package:flutter/material.dart';
import '../models/restaurant.dart';

const double _zarConversionRate = 18.5;
String _formatZar(double amount) =>
    'R${(amount * _zarConversionRate).toStringAsFixed(2)}';

// ── Simple order model ────────────────────────────────────────────────────────
class PlacedOrder {
  final Map<Item, int> items;
  final DateTime placedAt;
  final double total;

  PlacedOrder({
    required this.items,
    required this.placedAt,
    required this.total,
  });
}

// ── Orders page ───────────────────────────────────────────────────────────────
class OrdersPage extends StatelessWidget {
  const OrdersPage({
    super.key,
    required this.orders,
    required this.onGoToPaymentMethods,
    required this.onCancelOrder,
    required this.onAddMore,
  });

  final List<PlacedOrder> orders;
  final VoidCallback onGoToPaymentMethods;
  final void Function(int) onCancelOrder;
  final VoidCallback onAddMore;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No orders yet',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Browse Explore, add items and checkout!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      )),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onAddMore,
                child: const Text('Add more'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('My Orders (${orders.length})')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          // Show newest first
          final originalIndex = orders.length - 1 - index;
          final order = orders[originalIndex];
          final orderNumber = orders.length - index;
          final itemCount =
              order.items.values.fold(0, (sum, qty) => sum + qty);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Order header ──────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #$orderNumber',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        label: const Text('Pending Payment'),
                        backgroundColor: Colors.orange.shade100,
                        labelStyle: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Placed: ${order.placedAt.day}/${order.placedAt.month}/${order.placedAt.year} '
                    'at ${order.placedAt.hour}:${order.placedAt.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),

                  // ── Order items ───────────────────────────────────────────
                  ...order.items.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              e.key.imageUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'x${e.value}  ${e.key.name}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            _formatZar(e.key.price * e.value),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),

                  // ── Total ─────────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total ($itemCount item${itemCount > 1 ? 's' : ''})',
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(
                        _formatZar(order.total),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => onCancelOrder(originalIndex),
                        child: const Text('Cancel order'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onAddMore,
                        child: const Text('Add more'),
                      ),
                    ],
                  ),

                  // ── Pay Now button ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.payment),
                      label: const Text('Pay Now'),
                      onPressed: onGoToPaymentMethods,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}