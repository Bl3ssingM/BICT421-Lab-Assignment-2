/// Describes a single application user.
class User {
  final String fullName;
  final String role;
  final String profilePicture; // asset path or network URL
  final int points;

  const User({
    required this.fullName,
    required this.role,
    required this.profilePicture,
    required this.points,
  });

  // ── Sample data ─────────────────────────────────────────────────────────────
  static const sample = User(
    fullName: 'Stef',
    role: 'Flutterista',
    profilePicture: 'assets/images/user.jpg', // add your own asset
    points: 100,
  );
}