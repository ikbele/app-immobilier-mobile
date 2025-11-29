import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Client client;
  late Databases databases;
  late Account account;
  
  String? userId;
  List<Map<String, dynamic>> favoriteProperties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    client = Client()
      ..setEndpoint('https://nyc.cloud.appwrite.io/v1')
      ..setProject('6929cfe0000789817066');
    databases = Databases(client);
    account = Account(client);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      // Récupérer l'utilisateur connecté
      final user = await account.get();
      userId = user.$id;

      // Récupérer les favoris de l'utilisateur
      final response = await databases.listDocuments(
        databaseId: '6929e1e300094da69676',
        collectionId: 'favorites', // ID de votre collection favorites
        queries: [
          Query.equal('userId', userId!),
        ],
      );

      // Pour chaque favori, récupérer les détails de la propriété
      List<Map<String, dynamic>> properties = [];
      for (var favorite in response.documents) {
        try {
          final propertyDoc = await databases.getDocument(
            databaseId: '6929e1e300094da69676',
            collectionId: 'properties',
            documentId: favorite.data['propertyId'],
          );
          
          properties.add({
            'favoriteId': favorite.$id,
            'propertyId': propertyDoc.$id,
            ...propertyDoc.data,
          });
        } catch (e) {
          print('Error loading property: $e');
        }
      }

      setState(() {
        favoriteProperties = properties;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(String favoriteId, int index) async {
    try {
      await databases.deleteDocument(
        databaseId: '6929e1e300094da69676',
        collectionId: 'favorites',
        documentId: favoriteId,
      );

      setState(() {
        favoriteProperties.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Retiré des favoris'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B263B),
        elevation: 0,
        title: const Text(
          'Mes Favoris',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: favoriteProperties.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aucun favori',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des propriétés à vos favoris',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favoriteProperties.length,
              itemBuilder: (context, index) {
                final property = favoriteProperties[index];
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B263B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                                property['imageUrl'] ?? 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.home,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _removeFavorite(
                                    property['favoriteId'],
                                    index,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Informations
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property['title'] ?? 'Sans titre',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Color(0xFFD4AF37),
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          property['localisation'] ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFFB0B8C1),
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                '${property['prix']?.toStringAsFixed(0) ?? '0'} DT',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}