import 'package:flutter/material.dart';
import 'package:makan_mana/features/onboarding/presentation/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/presentation/auth_page.dart';
import 'firebase_options.dart';
import 'core/theme/app_colors.dart';

import 'dart:io';

import 'main_navigation_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = PetaHttpOverrides();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  runApp(ProviderScope(child: MakanManaApp(seenOnboarding: seenOnboarding)));
}

class MakanManaApp extends StatelessWidget {
  final bool seenOnboarding;
  const MakanManaApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MakanMana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          error: AppColors.error,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cardColor,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
      ),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    if (!seenOnboarding) {
      return const OnboardingScreen();
    }

    return const AuthGate();
  }
}

class PetaHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent = 'MakanManaApp/1.0 (kevinlidan12@gmail.com)';
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }

        return const AuthPage();
      },
    );
  }
}
