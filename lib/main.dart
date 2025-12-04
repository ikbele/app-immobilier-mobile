import 'package:flutter/material.dart';

// 📱 PAGES
import 'screens/ImprovedWelcomePage.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/profile_page.dart';
import 'screens/ManagePropertiesPage.dart';
import 'screens/FavoritesPage.dart';
import 'screens/ChatPage.dart';
import 'screens/ConversationsPage.dart';
import 'screens/PropertyDetailPage.dart';
import 'screens/MapPage.dart'; // 🗺️ Nouvelle page carte

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biens Premium',

      // 🎨 Thème sombre
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        primaryColor: const Color(0xFFFFD700),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFFD700),
          secondary: const Color(0xFFFFA500),
          background: const Color(0xFF1A1A1A),
          surface: const Color(0xFF2A2A2A),
        ),
      ),

      // 🏠 Route initiale
      initialRoute: "/",

      // 🗺️ Routes statiques
      routes: {
        '/': (context) => const ImprovedWelcomePage(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/profile': (context) => const ProfilePage(),
        '/favorites': (context) => const FavoritesPage(),
        '/manageProperties': (context) => const ManagePropertiesPage(),
        '/conversations': (context) => const ConversationsPage(),
        '/map': (context) => const MapPage(), // ✨ Route de la carte
      },

      // 🔀 Routes dynamiques avec arguments
      onGenerateRoute: (settings) {
        // ROUTE CHAT avec arguments
        if (settings.name == "/chat") {
          final args = settings.arguments as Map<String, dynamic>?;
          
          if (args == null) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text(
                    "Erreur: Arguments manquants pour le chat",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }
          
          return MaterialPageRoute(
            builder: (_) => ChatPage(
              receiverId: args['receiverId'],
              receiverName: args['receiverName'],
            ),
          );
        }

        // ROUTE DÉTAIL PROPRIÉTÉ avec arguments
        if (settings.name == "/propertyDetail") {
          final property = settings.arguments as Map<String, dynamic>?;
          
          if (property == null) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text(
                    "Erreur: Propriété introuvable",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }
          
          return MaterialPageRoute(
            builder: (_) => PropertyDetailPage(property: property),
          );
        }

        // ⚠️ Page 404 - Route non trouvée
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF2A2A2A),
              title: const Text("Erreur 404"),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Color(0xFFFFD700),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Page non trouvée",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "La page que vous recherchez n'existe pas",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.of(_).pushReplacementNamed('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Retour à l\'accueil',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}