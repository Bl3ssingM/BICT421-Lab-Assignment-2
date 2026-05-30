import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  List<Map<String, String>> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentsJson = prefs.getString('payments') ?? '[]';
    if (!mounted) return;
    setState(() {
      _payments = List<Map<String, String>>.from(jsonDecode(paymentsJson));
    });
  }

  String _maskCardNumber(String cardNumber) {
    final digitsOnly = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 4) return cardNumber;
    return '•••• •••• •••• ${digitsOnly.substring(digitsOnly.length - 4)}';
  }

  String _buildDisplayTitle(Map<String, String> payment) {
    final nickname = payment['nickname'] ?? '';
    final cardholder = payment['cardholder'] ?? '';
    final last4 = payment['last4'] ?? '';

    if (nickname.isNotEmpty) return nickname;
    if (cardholder.isNotEmpty && last4.isNotEmpty) {
      return '$cardholder •••• $last4';
    }
    return payment['label'] ?? 'Saved card';
  }

  String _buildDisplaySubtitle(Map<String, String> payment) {
    final maskedNumber = payment['maskedNumber'] ?? '';
    final expiry = payment['expiry'] ?? '';
    final cardholder = payment['cardholder'] ?? '';

    final parts = <String>[];
    if (cardholder.isNotEmpty) parts.add(cardholder);
    if (maskedNumber.isNotEmpty) parts.add(maskedNumber);
    if (expiry.isNotEmpty) parts.add('Expiry $expiry');
    if (parts.isEmpty) return payment['details'] ?? '';
    return parts.join(' • ');
  }

  Future<void> _addPayment({
    required String nickname,
    required String cardholder,
    required String cardNumber,
    required String expiry,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final digitsOnly = cardNumber.replaceAll(RegExp(r'\D'), '');
    final last4 = digitsOnly.length >= 4
        ? digitsOnly.substring(digitsOnly.length - 4)
        : digitsOnly;
    _payments.add({
      'nickname': nickname,
      'cardholder': cardholder,
      'maskedNumber': _maskCardNumber(cardNumber),
      'last4': last4,
      'expiry': expiry,
      'label': nickname.isNotEmpty ? nickname : 'Card ending $last4',
      'details': '$cardholder • ${_maskCardNumber(cardNumber)} • Expiry $expiry',
    });
    await prefs.setString('payments', jsonEncode(_payments));
    if (mounted) setState(() {});
  }

  Future<void> _removePayment(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _payments.removeAt(index);
    await prefs.setString('payments', jsonEncode(_payments));
    if (mounted) setState(() {});
  }

  Future<void> _openAddPaymentSheet() async {
    final nicknameController = TextEditingController();
    final cardholderController = TextEditingController();
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add card details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ..._payments.asMap().entries.map(
                      (entry) => ListTile(
                        title: Text(_buildDisplayTitle(entry.value)),
                        subtitle: Text(_buildDisplaySubtitle(entry.value)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _removePayment(entry.key);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                const SizedBox(height: 8),
                TextField(
                  controller: nicknameController,
                  decoration: const InputDecoration(
                    labelText: 'Card nickname',
                    hintText: 'Personal Visa',
                  ),
                ),
                TextField(
                  controller: cardholderController,
                  decoration: const InputDecoration(
                    labelText: 'Cardholder name',
                    hintText: 'Name on card',
                  ),
                ),
                TextField(
                  controller: cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Card number',
                    hintText: '1234 5678 9012 3456',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expiryController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: 'Expiry',
                          hintText: 'MM/YY',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'CVV is used for this mock form only and is not saved.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    final nickname = nicknameController.text.trim();
                    final cardholder = cardholderController.text.trim();
                    final cardNumber = cardNumberController.text.trim();
                    final expiry = expiryController.text.trim();

                    if (cardholder.isEmpty || cardNumber.isEmpty || expiry.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter cardholder name, card number, and expiry.'),
                        ),
                      );
                      return;
                    }

                    await _addPayment(
                      nickname: nickname,
                      cardholder: cardholder,
                      cardNumber: cardNumber,
                      expiry: expiry,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Card saved')),
                    );
                  },
                  child: const Text('Save card'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment methods')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Choose or add a payment method before checking out.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (_payments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No payment methods saved yet.'),
            ),
          ..._payments.asMap().entries.map(
                (entry) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.credit_card_outlined),
                    title: Text(_buildDisplayTitle(entry.value)),
                    subtitle: Text(_buildDisplaySubtitle(entry.value)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _removePayment(entry.key),
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _openAddPaymentSheet,
            icon: const Icon(Icons.add_card_outlined),
            label: const Text('Add payment method'),
          ),
        ],
      ),
    );
  }
}