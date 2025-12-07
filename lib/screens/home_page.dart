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
  List<Map<String, dynamic>> filteredProducts = [];
  Set<String> favoritePropertyIds = {};
  bool _isLoading = true;

  // 🌓 Mode sombre/clair
  bool _isDarkMode = true;

  // 🔍 Contrôleurs de recherche et filtres
  final TextEditingController _searchController = TextEditingController();
  String _selectedTypeFilter = 'Tous';
  double _minPrice = 0;
  double _maxPrice = 1000000;
  RangeValues _priceRange = const RangeValues(0, 1000000);

  final List<String> _propertyTypes = ['Tous', 'Villa', 'Appartement', 'Maison', 'Studio', 'Penthouse'];

  // 🎨 Couleurs dynamiques selon le thème
  Color get _backgroundColor => _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
  Color get _cardColor => _isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);
  Color get _textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get _textSecondaryColor => _isDarkMode ? Colors.white70 : Colors.black54;
  Color get _borderColor => _isDarkMode ? const Color(0xFFFFD700).withOpacity(0.3) : const Color(0xFFFFD700).withOpacity(0.2);

  @override
  void initState() {
    super.initState();
    client = Client()
      ..setEndpoint('https://nyc.cloud.appwrite.io/v1')
      ..setProject('6929cfe0000789817066');
    databases = Databases(client);
    account = Account(client);
    _loadData();

    _searchController.addListener(_applyFilters);
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

      List<Map<String, dynamic>> loadedProducts = [];

      for (var doc in propertiesResponse.documents) {
        Map<String, dynamic> property = {'id': doc.$id, ...doc.data};
        loadedProducts.add(property);
      }

      setState(() {
        products = loadedProducts;
        filteredProducts = loadedProducts;
        _isLoading = false;
        
        if (products.isNotEmpty) {
          _minPrice = products.map((p) => (p['prix'] ?? 0).toDouble()).reduce((a, b) => a < b ? a : b);
          _maxPrice = products.map((p) => (p['prix'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b);
          _priceRange = RangeValues(_minPrice, _maxPrice);
        }
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      filteredProducts = products.where((property) {
        final searchLower = _searchController.text.toLowerCase();
        final matchesSearch = searchLower.isEmpty ||
            (property['title'] ?? '').toLowerCase().contains(searchLower) ||
            (property['localisation'] ?? '').toLowerCase().contains(searchLower) ||
            (property['description'] ?? '').toLowerCase().contains(searchLower);

        final matchesType = _selectedTypeFilter == 'Tous' ||
            property['type'] == _selectedTypeFilter;

        final price = (property['prix'] ?? 0).toDouble();
        final matchesPrice = price >= _priceRange.start && price <= _priceRange.end;

        return matchesSearch && matchesType && matchesPrice;
      }).toList();
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filtres avancés',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Type de propriété',
                style: TextStyle(color: _textSecondaryColor, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _propertyTypes.map((type) {
                  final isSelected = _selectedTypeFilter == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedTypeFilter = type;
                      });
                    },
                    selectedColor: const Color(0xFFFFD700),
                    backgroundColor: _isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[300],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : _textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Fourchette de prix',
                style: TextStyle(color: _textSecondaryColor, fontSize: 14),
              ),
              const SizedBox(height: 10),
              RangeSlider(
                values: _priceRange,
                min: _minPrice,
                max: _maxPrice,
                divisions: 20,
                activeColor: const Color(0xFFFFD700),
                inactiveColor: _isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[300],
                labels: RangeLabels(
                  '${_priceRange.start.toInt()} DT',
                  '${_priceRange.end.toInt()} DT',
                ),
                onChanged: (RangeValues values) {
                  setModalState(() {
                    _priceRange = values;
                  });
                },
              ),
              Text(
                'De ${_priceRange.start.toInt()} DT à ${_priceRange.end.toInt()} DT',
                style: const TextStyle(color: Color(0xFFFFD700)),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedTypeFilter = 'Tous';
                          _priceRange = RangeValues(_minPrice, _maxPrice);
                        });
                        setState(() {
                          _selectedTypeFilter = 'Tous';
                          _priceRange = RangeValues(_minPrice, _maxPrice);
                        });
                        _applyFilters();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFD700)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Réinitialiser',
                        style: TextStyle(color: Color(0xFFFFD700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _applyFilters();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Appliquer',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await account.deleteSessions();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  Future<void> _toggleFavorite(String propertyId) async {
    if (userId == null) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _showLoginRequiredMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connectez-vous pour accéder à $feature'),
        backgroundColor: const Color(0xFFFFA500),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Se connecter',
          textColor: const Color(0xFF1A1A1A),
          onPressed: () => Navigator.pushNamed(context, '/login'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _cardColor,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ).createShader(bounds),
          child: Text(
            "Biens Premium",
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          // 🌓 Bouton Mode Nuit/Jour
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: const Color(0xFFFFD700),
            ),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
            tooltip: _isDarkMode ? 'Mode Jour' : 'Mode Nuit',
          ),
          IconButton(
            icon: const Icon(Icons.map, color: Color(0xFFFFD700)),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/map',
                arguments: filteredProducts,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFFD700)),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
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
      body: _buildHomeContent(),
      floatingActionButton: userId != null
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, "/manageProperties");
                if (result == true) {
                  setState(() => _isLoading = true);
                  await _loadData();
                }
              },
              backgroundColor: const Color(0xFFFFD700),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.grey,
        backgroundColor: _cardColor,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            if (userId == null) {
              _showLoginRequiredMessage('vos favoris');
            } else {
              Navigator.pushNamed(context, "/favorites");
            }
          } else if (index == 2) {
            if (userId == null) {
              _showLoginRequiredMessage('vos messages');
            } else {
              Navigator.pushNamed(context, '/conversations');
            }
          } else if (index == 3) {
            if (userId == null) {
              _showLoginRequiredMessage('votre profil');
            } else {
              Navigator.pushNamed(context, "/profile");
            }
          } else {
            setState(() => _currentIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoris"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: _cardColor,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: _textColor),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une propriété...',
                    hintStyle: TextStyle(color: _textSecondaryColor),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
                    filled: true,
                    fillColor: _backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune, color: Colors.black),
                  onPressed: _showFilterDialog,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${filteredProducts.length} propriété${filteredProducts.length > 1 ? 's' : ''} trouvée${filteredProducts.length > 1 ? 's' : ''}',
                style: TextStyle(color: _textSecondaryColor, fontSize: 14),
              ),
              if (_selectedTypeFilter != 'Tous' || _priceRange.start != _minPrice || _priceRange.end != _maxPrice)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedTypeFilter = 'Tous';
                      _priceRange = RangeValues(_minPrice, _maxPrice);
                      _searchController.clear();
                      _applyFilters();
                    });
                  },
                  icon: const Icon(Icons.clear, size: 16, color: Color(0xFFFFD700)),
                  label: const Text(
                    'Effacer filtres',
                    style: TextStyle(color: Color(0xFFFFD700)),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Text(
                    "Aucune propriété trouvée",
                    style: TextStyle(color: _textColor, fontSize: 18),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () => _showPropertyActions(product),
                      child: _buildPropertyCard(product),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showPropertyActions(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (product['ownerName'] != null || product['ownerEmail'] != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.1),
                      const Color(0xFFFFA500).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.black, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Propriétaire', style: TextStyle(color: _isDarkMode ? Colors.grey : Colors.grey[600], fontSize: 12)),
                          Text(
                            product['ownerName'] ?? 'Inconnu',
                            style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (product['ownerEmail'] != null && product['ownerEmail'].toString().isNotEmpty)
                            Text(
                              product['ownerEmail'],
                              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.visibility, color: Color(0xFF1A1A1A)),
              ),
              title: Text('Voir les détails', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/propertyDetail', arguments: product);
              },
            ),
            if (product['lat'] != null && product['lng'] != null) ...[
              Divider(color: _isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[300]),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on, color: Color(0xFF1A1A1A)),
                ),
                title: Text('Voir sur la carte', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  product['localisation'] ?? 'Localisation',
                  style: TextStyle(color: _isDarkMode ? Colors.grey : Colors.grey[600], fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/map',
                    arguments: [product],
                  );
                },
              ),
            ],
            if (userId != null) ...[
              Divider(color: _isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[300]),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat_bubble, color: Color(0xFF1A1A1A)),
                ),
                title: Text('Contacter le propriétaire', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: {
                      'receiverId': product['ownerId'] ?? 'default_owner_id',
                      'receiverName': product['ownerName'] ?? 'Propriétaire',
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
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
                Image.network(
                  product['imageUrl'] ?? 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: _isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[300],
                      child: const Icon(Icons.home, size: 40, color: Color(0xFFFFD700)),
                    );
                  },
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
                        favoritePropertyIds.contains(product['id']) ? Icons.favorite : Icons.favorite_border,
                        color: favoritePropertyIds.contains(product['id']) ? const Color(0xFF1A1A1A) : const Color(0xFFFFD700),
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
                children: [
                  Text(
                    product['title'] ?? 'Sans titre',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Color(0xFFFFD700)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (product['lat'] != null && product['lng'] != null) {
                              Navigator.pushNamed(
                                context,
                                '/map',
                                arguments: [product],
                              );
                            }
                          },
                          child: Text(
                            product['localisation'] ?? '',
                            style: TextStyle(
                              color: _isDarkMode ? Colors.grey : Colors.grey[600],
                              fontSize: 11,
                              decoration: TextDecoration.underline,
                              decorationColor: _isDarkMode ? Colors.grey : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (product['ownerName'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person, size: 10, color: Color(0xFFFFD700)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              product['ownerName'],
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    "${product['prix'] ?? 0} DT",
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}