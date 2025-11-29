import 'package:app_immobilier_mobile/models/models.dart';
import 'package:app_immobilier_mobile/screens/ManagePropertiesPage.dart';
import 'package:app_immobilier_mobile/screens/FavoritesPage.dart';
import 'package:app_immobilier_mobile/screens/PaymentPage.dart';
import 'package:flutter/material.dart';

// 👉 Import des pages
import 'screens/welcome_page.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application Immobilier',

      // 👉 Page de démarrage
      home: const WelcomePage(),

      // 👉 Routes déclarées
      routes: {
        "/welcome": (context) => const WelcomePage(),
        "/home": (context) => const HomePage(),
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/profile": (context) => const ProfilePage(),
        "/manageProperties": (context) => const ManagePropertiesPage(),
       "/favorites": (context) => const FavoritesPage(),
      "/payment": (context) => const PaymentPage(),

      },
    );
  }
}
