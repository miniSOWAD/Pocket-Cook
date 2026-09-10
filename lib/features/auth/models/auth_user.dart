class AuthUser {
  const AuthUser({required this.uid, required this.name, required this.email, this.isDemo = false});
  final String uid;
  final String name;
  final String email;
  final bool isDemo;
}
