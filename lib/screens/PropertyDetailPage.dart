import 'package:flutter/material.dart';

class PropertyDetailPage extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2A2A2A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détails du bien',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // *** IMAGE ***
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Image.network(
                property['imageUrl'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Icon(Icons.home, color: Color(0xFFFFD700), size: 80),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // *** TITRE + PRIX ***
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property['title'] ?? "Sans titre",
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ShaderMask(
                        shaderCallback: (bounds) =>
                            const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
                                .createShader(bounds),
                        child: Text(
                          "${property['prix'] ?? 0} DT",
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // *** LOCALISATION ***
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFFFD700)),
                      const SizedBox(width: 6),
                      Text(
                        property['localisation'] ?? "",
                        style: const TextStyle(color: Color(0xFFB0B8C1)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // *** TYPE ***
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      property['type'] ?? "",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // *** DESCRIPTION ***
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    property['description'] ?? "Aucune description",
                    style: const TextStyle(color: Color(0xFFB0B8C1), height: 1.5),
                  ),

                  const SizedBox(height: 30),

                  // *** BOUTONS ***
                  Row(
                    children: [
                      // ===== CONTACTER =====
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/chat",
                              arguments: {
                                "receiverId": property["ownerId"] ?? "x",
                                "receiverName": property["ownerName"] ?? "Propriétaire",
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text("Contacter"),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ===== APPELER =====
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, color: Color(0xFFFFD700)),
                          label: const Text(
                            "Appeler",
                            style: TextStyle(color: Color(0xFFFFD700)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFD700)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
