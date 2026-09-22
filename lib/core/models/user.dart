/// Minimal wrapper around FirebaseAuth's User — keeps the rest of the app
/// from depending on Firebase types directly.
class AppUser {
  final String uid;
  final String? email;

  const AppUser({required this.uid, this.email});
}
