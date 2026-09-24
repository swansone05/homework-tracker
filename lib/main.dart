import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'firebase_options.dart';
import 'views/login_screen.dart';
import 'views/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HomeworkTrackerApp());
}

class HomeworkTrackerApp extends StatelessWidget {
  const HomeworkTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homework Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Decides which screen to show based on the Firebase login state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase is still checking the current authentication state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const FallingDotsLoadingScreen();
        }

        // A Firebase user exists.
        if (snapshot.hasData) {
          return const MainNavigation();
        }

        // Nobody is logged in.
        return const LoginScreen();
      },
    );
  }
}

class FallingDotsLoadingScreen extends StatelessWidget {
  const FallingDotsLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.blue,
          size: 50,
        ),
      ),
    );
  }
}