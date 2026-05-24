import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// constants.dart not used here — import removed to clean analyzer warning
import 'models/auth.dart';
import 'providers/cart_provider.dart';
import 'providers/favourites_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_page.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(
    // ── MultiProvider wraps the entire app so all providers are accessible
    // from any widget in the tree — this is the structured state approach
    // that replaces passing callbacks through every parent widget.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
      ],
      child: const Yummy(),
    ),
  );
}

class Yummy extends StatefulWidget {
  const Yummy({super.key});

  @override
  State<Yummy> createState() => _YummyState();
}

class _YummyState extends State<Yummy> {
  final _auth = Auth();

  @override
  void initState() {
    super.initState();
    _auth.clearSavedSession();
  }

  // ── Redirect ──────────────────────────────────────────────────────────────
  Future<String?> _appRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final loggedIn = await _auth.loggedIn;
    if (!loggedIn) return '/login';
    return null;
  }

  // ── Router ────────────────────────────────────────────────────────────────
  late final _router = GoRouter(
    initialLocation: '/login',
    redirect: _appRedirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(
          onLogIn: (Credentials credentials) async {
            await _auth.signIn(credentials.username, credentials.password);
            if (context.mounted) context.go('/home');
          },
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => MainShell(auth: _auth),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // ThemeProvider drives the MaterialApp theme — widgets rebuild
    // automatically when ThemeProvider calls notifyListeners().
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Yummy',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorSchemeSeed: themeProvider.colorSelected.color,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: themeProvider.colorSelected.color,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
    );
  }
}