import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Client client;
  late Databases databases;
  late Account account;

  Map<String, dynamic>? userData;
  bool _isLoading = true;
  String? _profileImageUrl;
  String? phoneNumber;
  
  int myPropertiesCount = 0;
  int favoritesCount = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    client = Client()
      ..setEndpoint('https://nyc.cloud.appwrite.io/v1')
      ..setProject('6929cfe0000789817066');
    databases = Databases(client);
    account = Account(client);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Charger les données de l'utilisateur
      final user = await account.get();
      userId = user.$id;
      
      setState(() {
        userData = user.toMap();
      });

      // Charger le numéro de téléphone depuis la collection users
      try {
        final userDoc = await databases.getDocument(
          databaseId: '6929e1e300094da69676',
          collectionId: 'users',
          documentId: userId!,
        );
        phoneNumber = userDoc.data['phone'];
      } catch (e) {
        print('No phone number found: $e');
        phoneNumber = null;
      }

      // Charger le nombre de propriétés de l'utilisateur
      final propertiesResponse = await databases.listDocuments(
        databaseId: '6929e1e300094da69676',
        collectionId: 'properties',
        queries: [
          Query.equal('ownerId', userId!),
        ],
      );

      // Charger le nombre de favoris
      final favoritesResponse = await databases.listDocuments(
        databaseId: '6929e1e300094da69676',
        collectionId: 'favorites',
        queries: [
          Query.equal('userId', userId!),
        ],
      );

      setState(() {
        myPropertiesCount = propertiesResponse.documents.length;
        favoritesCount = favoritesResponse.documents.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de chargement du profil')),
        );
      }
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
        title: const Text('Mon Profil', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD4AF37)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1B263B),
                  title: const Text(
                    'Déconnexion',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Voulez-vous vraiment vous déconnecter ?',
                    style: TextStyle(color: Color(0xFFB0B8C1)),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Déconnexion',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec photo de profil
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1B263B),
                    Colors.black,
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFFD4AF37), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFD4AF37).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _profileImageUrl != null
                          ? Image.network(
                              _profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF2C3E50),
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFFD4AF37),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: const Color(0xFF2C3E50),
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userData?['name'] ?? 'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData?['email'] ?? '',
                    style: const TextStyle(
                      color: Color(0xFFB0B8C1),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Options du profil
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    icon: Icons.home_work_outlined,
                    title: 'Mes annonces',
                    subtitle: myPropertiesCount > 0 
                        ? '$myPropertiesCount ${myPropertiesCount > 1 ? "biens publiés" : "bien publié"}'
                        : 'Aucun bien publié',
                    onTap: () {
                      Navigator.pushNamed(context, '/manageProperties');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    icon: Icons.favorite_border,
                    title: 'Mes favoris',
                    subtitle: favoritesCount > 0
                        ? '$favoritesCount ${favoritesCount > 1 ? "biens sauvegardés" : "bien sauvegardé"}'
                        : 'Aucun favori',
                    onTap: () {
                      Navigator.pushNamed(context, '/favorites');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    icon: Icons.payment,
                    title: 'Paiements',
                    onTap: () {
                      Navigator.pushNamed(context, '/payment');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à venir'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    icon: Icons.security,
                    title: 'Sécurité et confidentialité',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à venir'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Aide et support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à venir'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2C3E50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFFD4AF37),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Informations personnelles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.person,
            label: 'Nom',
            value: userData?['name'] ?? 'Non renseigné',
          ),
          const Divider(color: Color(0xFF2C3E50), height: 32),
          _buildInfoRow(
            icon: Icons.email,
            label: 'Email',
            value: userData?['email'] ?? 'Non renseigné',
          ),
          const Divider(color: Color(0xFF2C3E50), height: 32),
          _buildInfoRow(
            icon: Icons.phone,
            label: 'Téléphone',
            value: phoneNumber ?? 'Non renseigné',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFD4AF37), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2C3E50),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFB0B8C1),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFB0B8C1),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}