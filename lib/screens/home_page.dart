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
      try {
        final user = await account.get();
        userId = user.$id;
        
        final favoritesResponse = await databases.listDocuments(
          databaseId: '6929e1e300094da69676',
          collectionId: 'favorites',
          queries: [Query.equal('userId', userId!)],
        );

        Set<String> favIds = {};
        for (var fav in favoritesResponse.documents) {
          favIds.add(fav.data['propertyId']);
        }
        
        setState(() {
          favoritePropertyIds = favIds;
        });
      } catch (e) {
        userId = null;
        favoritePropertyIds = {};
      }

      final propertiesResponse = await databases.listDocuments(
        databaseId: '6929e1e300094da69676',
        collectionId: 'properties',
      );

      setState(() {
        products = propertiesResponse.documents
            .map((doc) => {'id': doc.$id, ...doc.data})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await account.deleteSessions();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      print('Logout error: $e');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    }
  }

  Future<void> _toggleFavorite(String propertyId) async {
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Connectez-vous pour ajouter aux favoris'),
            backgroundColor: const Color(0xFFFFA500),
            action: SnackBarAction(
              label: 'Connexion',
              textColor: const Color(0xFF1A1A1A),
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
          ),
        );
      }
      return;
    }

    try {
      if (favoritePropertyIds.contains(propertyId)) {
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
        setState(() => favoritePropertyIds.remove(propertyId));
      } else {
        await databases.createDocument(
          databaseId: '6929e1e300094da69676',
          collectionId: 'favorites',
          documentId: ID.unique(),
          data: {
            'userId': userId!,
            'propertyId': propertyId,
          },
        );
        setState(() => favoritePropertyIds.add(propertyId));
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
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFFFD700),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2A2A2A),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ).createShader(bounds),
          child: const Text(
            "Biens Premium",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFFD700)),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFFFFD700)),
            onPressed: () {},
          ),
          // Bouton connexion/déconnexion selon l'état de l'utilisateur
          if (userId == null)
            IconButton(
              icon: const Icon(Icons.login, color: Color(0xFFFFD700)),
              onPressed: () => Navigator.pushNamed(context, '/login'),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFFFFD700)),
              onPressed: _logout,
            ),
        ],
      ),
      body: _currentIndex == 0 ? _buildHomeContent() : _buildOtherPages(),
      floatingActionButton: userId != null ? Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.pushNamed(context, "/manageProperties");
            if (result == true) {
              setState(() => _isLoading = true);
              await _loadData();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Color(0xFF1A1A1A), size: 28),
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: const Color(0xFF2A2A2A),
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
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Connectez-vous'),
                backgroundColor: const Color(0xFFFFA500),
                action: SnackBarAction(
                  label: 'Connexion',
                  textColor: const Color(0xFF1A1A1A),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
              ),
            );
          } else {
            Navigator.pushNamed(context, "/profile");
          }
        } else if (index == 2) {
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Connectez-vous'),
                backgroundColor: const Color(0xFFFFA500),
                action: SnackBarAction(
                  label: 'Connexion',
                  textColor: const Color(0xFF1A1A1A),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
              ),
            );
          } else {
            Navigator.pushNamed(context, "/favorites");
          }
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFFD700) : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFD700) : Colors.grey,
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
            Icon(Icons.home_work_outlined, size: 80, color: const Color(0xFFFFD700).withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'Aucune propriété',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFFB0B8C1),
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
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/payment', arguments: product);
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Image.network(
                          product['imageUrl'] ?? 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF3A3A3A),
                              child: const Icon(Icons.home, size: 40, color: Color(0xFFFFD700)),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _toggleFavorite(product['id']),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: favoritePropertyIds.contains(product['id'])
                                  ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
                                  : null,
                              color: favoritePropertyIds.contains(product['id']) ? null : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: favoritePropertyIds.contains(product['id'])
                                      ? const Color(0xFFFFD700).withOpacity(0.5)
                                      : Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              favoritePropertyIds.contains(product['id'])
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: favoritePropertyIds.contains(product['id'])
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFFFFD700),
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 12, color: Color(0xFFFFD700)),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    product['localisation'] ?? '',
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
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product['type'] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${product['prix']?.toStringAsFixed(0) ?? '0'} DT',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 80, color: const Color(0xFFFFD700).withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Panier',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFFB0B8C1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}