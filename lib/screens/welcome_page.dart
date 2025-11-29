import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 19),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO WITH ENHANCED STYLING
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2C3E50),
                      const Color.fromARGB(255, 1, 9, 16),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: -5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 3,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFD4AF37).withOpacity(0.3),
                          const Color(0xFF8B7355).withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/logo.jpeg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // TITLE TEXT
              const Text(
                "Votre plateforme immobilière moderne.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // SUBTITLE TEXT
              const Text(
                "Trouvez, explorez, publiez vos biens.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB0B8C1),
                  fontSize: 18,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/home");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 14, 15, 15),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 8,
                    shadowColor: const Color.fromARGB(255, 74, 74, 47).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Commencer",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}