import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:again/core/services/auth_service.dart';

part 'auth.g.dart';

@riverpod
AuthService authService(Ref ref) => AuthService();

/// null = logged out, User = logged in. Watched in main.dart to pick Login/Home.
@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authServiceProvider).authStateChanges;
}

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    final service = ref.read(authServiceProvider);
    state = await AsyncValue.guard(() async {
      try {
        await service.signIn(email, password);
      } on FirebaseAuthException catch (e) {
        throw service.friendlyError(e);
      }
    });
  }

  Future<void> signUp(String name, String email, String password) async {
    state = const AsyncLoading();
    final service = ref.read(authServiceProvider);
    state = await AsyncValue.guard(() async {
      try {
        await service.signUp(name, email, password);
      } on FirebaseAuthException catch (e) {
        throw service.friendlyError(e);
      }
    });
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }
}
