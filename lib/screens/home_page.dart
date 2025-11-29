import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late Client client;
  late Databases databases;
  late Account account;
  
  String? userId;
  List<Map<String, dynamic>> products = [];
  Set<String> favoritePropertyIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    client = Client()
      ..setEndpoint('https://nyc.cloud.appwrite.io/v1')
      ..setProject('6929cfe0000789817066');
    databases = Databases(client);
    account = Account(client);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Charger l'utilisateur
      final user = await account.get();
      userId = user.$id;

      // Charger les propriétés
      final propertiesResponse = await databases.listDocuments(
        databaseId: '6929e1e300094da69676',
        collectionId: 'properties',
      );

      // Charger les favoris de l'utilisateur
      final favoritesResponse = await databases.listDocuments(
        databaseId: '6929e1e300094da69676',
        collectionId: 'favorites',
        queries: [
          Query.equal('userId', userId!),
        ],
      );

      Set<String> favIds = {};
      for (var fav in favoritesResponse.documents) {
        favIds.add(fav.data['propertyId']);
      }

      setState(() {
        products = propertiesResponse.documents
            .map((doc) => {'id': doc.$id, ...doc.data})
            .toList();
        favoritePropertyIds = favIds;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(String propertyId) async {
    if (userId == null) return;

    try {
      if (favoritePropertyIds.contains(propertyId)) {
        // Retirer des favoris
        final favoritesResponse = await databases.listDocuments(
          databaseId: '6929e1e300094da69676',
          collectionId: 'favorites',
          queries: [
            Query.equal('userId', userId!),
            Query.equal('propertyId', propertyId),
          ],
        );

        if (favoritesResponse.documents.isNotEmpty) {
          await databases.deleteDocument(
            databaseId: '6929e1e300094da69676',
            collectionId: 'favorites',
            documentId: favoritesResponse.documents.first.$id,
          );
        }

        setState(() {
          favoritePropertyIds.remove(propertyId);
        });
      } else {
        // Ajouter aux favoris
        await databases.createDocument(
          databaseId: '6929e1e300094da69676',
          collectionId: 'favorites',
          documentId: ID.unique(),
          data: {
            'userId': userId!,
            'propertyId': propertyId,
          },
        );

        setState(() {
          favoritePropertyIds.add(propertyId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Biens Immobiliers",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.login, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            tooltip: 'Connexion',
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildHomeContent() : _buildOtherPages(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, "/manageProperties");
          // Si l'ajout a réussi, recharger les données
          if (result == true) {
            setState(() => _isLoading = true);
            await _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Liste actualisée !'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
            }
          }
        },
        backgroundColor: const Color(0xFFD4AF37),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Accueil", 0),
              _buildNavItem(Icons.shopping_cart_outlined, "Panier", 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.favorite_border, "Favoris", 2),
              _buildNavItem(Icons.person_outline, "Profil", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        if (index == 3) {
          Navigator.pushNamed(context, "/profile");
        } else if (index == 2) {
          Navigator.pushNamed(context, "/favorites");
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFD4AF37) : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFD4AF37) : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune propriété disponible',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85, // Augmenté pour réduire la hauteur totale
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            // Navigation vers la page de détails ou paiement
            Navigator.pushNamed(
              context,
              '/payment',
              arguments: product,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Image plus petite
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 120, // Hauteur fixe plus petite
                      width: double.infinity,
                      child: Image.network(
                        product['imageUrl'] ?? 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.home, size: 40, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          // Empêcher la propagation du tap au parent
                          _toggleFavorite(product['id']);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            favoritePropertyIds.contains(product['id'])
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: favoritePropertyIds.contains(product['id'])
                                ? Colors.red
                                : const Color(0xFFD4AF37),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Section d'informations plus grande
              Expanded(
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
                            product['title'] ?? 'Sans titre',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 12, color: Colors.grey),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  product['localisation'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.category, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                product['type'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${product['prix']?.toStringAsFixed(0) ?? '0'} DT',
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
        ),
        );
      },
    );
  }

  Widget _buildOtherPages() {
    String title = 'Panier';
    IconData icon = Icons.shopping_cart;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette section sera bientôt disponible',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}