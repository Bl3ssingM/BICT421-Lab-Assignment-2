import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../models/auth.dart';
import '../models/user.dart';
import 'kodeco_view.dart';

/// Shows the signed-in user's profile, a link to Kodeco, and a logout button.
class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
    required this.auth,
    required this.onLogOut,
    this.user = User.sample,
    this.onGoToOrders,
    this.changeTheme,
    this.changeColor,
    this.colorSelected,
  });

  final Auth auth;
  final VoidCallback onLogOut;
  final User user;
  final VoidCallback? onGoToOrders;
  final void Function(bool)? changeTheme;
  final void Function(int)? changeColor;
  final ColorSelection? colorSelected;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _displayName = 'Guest';
  List<String> _addresses = [];
  List<Map<String, String>> _payments = [];
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadPreferences();
  }

  Future<void> _loadUsername() async {
    final name = await widget.auth.savedUsername;
    if (mounted) setState(() => _displayName = name);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString('addresses') ?? '[]';
    final paymentsJson = prefs.getString('payments') ?? '[]';
    setState(() {
      _addresses = List<String>.from(jsonDecode(addressesJson));
      _payments = List<Map<String, String>>.from(jsonDecode(paymentsJson));
      _notificationsEnabled = prefs.getBool('pref_notifications') ?? true;
    });
  }

  Future<void> _launchKodeco() async {
    // Open Kodeco inside the app when possible
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const KodecoView()),
    );
  }

  Future<void> _saveDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
    if (mounted) setState(() => _displayName = name);
  }

  Future<void> _addAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    _addresses.add(address);
    await prefs.setString('addresses', jsonEncode(_addresses));
    if (mounted) setState(() {});
  }

  Future<void> _removeAddress(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _addresses.removeAt(index);
    await prefs.setString('addresses', jsonEncode(_addresses));
    if (mounted) setState(() {});
  }

  Future<void> _addPayment(String label, String details) async {
    final prefs = await SharedPreferences.getInstance();
    _payments.add({'label': label, 'details': details});
    await prefs.setString('payments', jsonEncode(_payments));
    if (mounted) setState(() {});
  }

  Future<void> _removePayment(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _payments.removeAt(index);
    await prefs.setString('payments', jsonEncode(_payments));
    if (mounted) setState(() {});
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_notifications', value);
    if (mounted) setState(() => _notificationsEnabled = value);
  }

  Future<void> _clearAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await widget.auth.signOut();
    if (mounted) widget.onLogOut();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Profile card ─────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 56,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.role,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Chip(
                  avatar: const Icon(Icons.star_rounded, size: 16),
                  label: Text('${widget.user.points} points'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          // ── Edit profile ─────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Edit profile'),
            subtitle: Text(_displayName),
            onTap: () async {
              final controller = TextEditingController(text: _displayName);
              final result = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Edit display name'),
                  content: TextField(controller: controller),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
                  ],
                ),
              );
              if (result != null && result.trim().isNotEmpty) {
                await _saveDisplayName(result.trim());
              }
            },
          ),

          const Divider(),

          // ── View Kodeco (in-app) ──────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.open_in_new_rounded),
            title: const Text('View Kodeco'),
            onTap: _launchKodeco,
          ),

          const Divider(),

          // ── Saved addresses ───────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Saved addresses'),
            subtitle: Text(_addresses.isEmpty ? 'No saved addresses' : '${_addresses.length} saved'),
            onTap: () async {
              await showModalBottomSheet<void>(
                context: context,
                builder: (context) {
                  final addrController = TextEditingController();
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_addresses.isEmpty) const Text('No addresses saved.'),
                        ..._addresses.asMap().entries.map((e) => ListTile(
                              title: Text(e.value),
                              trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () { _removeAddress(e.key); Navigator.pop(context); }),
                            )),
                        const SizedBox(height: 8),
                        TextField(controller: addrController, decoration: const InputDecoration(hintText: 'Enter new address')),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: () { if (addrController.text.trim().isNotEmpty) { _addAddress(addrController.text.trim()); Navigator.pop(context); } }, child: const Text('Add')),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const Divider(),

          // ── Payment methods (mock) ───────────────────────────────────
          ListTile(
            leading: const Icon(Icons.payment_outlined),
            title: const Text('Payment methods'),
            subtitle: Text(_payments.isEmpty ? 'No payment methods' : '${_payments.length} methods'),
            onTap: () async {
              final labelController = TextEditingController();
              final detailsController = TextEditingController();
              await showModalBottomSheet<void>(
                context: context,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ..._payments.asMap().entries.map((e) => ListTile(
                              title: Text(e.value['label'] ?? ''),
                              subtitle: Text(e.value['details'] ?? ''),
                              trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () { _removePayment(e.key); Navigator.pop(context); }),
                            )),
                        TextField(controller: labelController, decoration: const InputDecoration(hintText: 'Card label (e.g., Visa •••• 1234)')),
                        TextField(controller: detailsController, decoration: const InputDecoration(hintText: 'Details (mock)')),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: () { if (labelController.text.trim().isNotEmpty) { _addPayment(labelController.text.trim(), detailsController.text.trim()); Navigator.pop(context); } }, child: const Text('Add')),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const Divider(),

          // ── Preferences ───────────────────────────────────────────────
          SwitchListTile(
            title: const Text('Enable notifications'),
            value: _notificationsEnabled,
            onChanged: (v) => _toggleNotifications(v),
            secondary: const Icon(Icons.notifications_outlined),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Theme'),
            subtitle: Text(widget.colorSelected?.label ?? 'Default'),
            onTap: () async {
              // Quick color picker dialog
              final choice = await showDialog<int?>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('Select color theme'),
                  children: ColorSelection.values.map((c) => SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, ColorSelection.values.indexOf(c)),
                        child: Row(children: [Icon(Icons.circle, color: c.color), const SizedBox(width: 8), Text(c.label)]),
                      )).toList(),
                ),
              );
              if (choice != null && widget.changeColor != null) widget.changeColor!(choice);
            },
          ),

          const Divider(),

          // ── Actions: Orders, Feedback, Invite, Clear ─────────────────
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('View orders'),
            onTap: widget.onGoToOrders,
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send feedback'),
            onTap: () async {
              final uri = Uri.parse('mailto:support@example.com?subject=App%20Feedback');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard_outlined),
            title: const Text('Invite friends'),
            subtitle: const Text('Copy invite code'),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: 'INVITE-CODE-123'));
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite code copied to clipboard')));
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: colorScheme.error),
            title: Text('Clear account', style: TextStyle(color: colorScheme.error)),
            onTap: () async {
              final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                    title: const Text('Clear account?'),
                    content: const Text('This will clear local data and sign you out.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Clear'))],
                  ));
              if (confirm == true) await _clearAccount();
            },
          ),

          const Divider(),

          // ── Log out ──────────────────────────────────────────────────────
          ListTile(
            leading: Icon(Icons.logout_rounded, color: colorScheme.error),
            title: Text(
              'Log out',
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: widget.onLogOut,
          ),
        ],
      ),
    );
  }
}