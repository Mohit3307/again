import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:again/firebase_options.dart';
import 'package:again/features/auth.dart';
import 'package:again/pages/auth/login_screen.dart';
import 'package:again/pages/home/home_screen.dart'; // NEW

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Again',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
      ),

      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) =>
          user == null ? const LoginScreen() : const HomeScreen(), // CHANGED

      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
