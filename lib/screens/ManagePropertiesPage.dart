import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class ManagePropertiesPage extends StatefulWidget {
  const ManagePropertiesPage({super.key});

  @override
  State<ManagePropertiesPage> createState() => _ManagePropertiesPageState();
}

class _ManagePropertiesPageState extends State<ManagePropertiesPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  String _selectedType = 'Villa';
  final List<String> _propertyTypes = ['Villa', 'Appartement', 'Maison', 'Studio', 'Penthouse'];
  
  bool _isLoading = false;
  bool _isLoadingProperties = true;
  
  late Client client;
  late Databases databases;
  late Account account;
  
  String? userId;
  List<Map<String, dynamic>> myProperties = [];
  
  int _selectedTab = 0; // 0 = Ajouter, 1 = Mes propriétés

  @override
  void initState() {
    super.initState();
    client = Client()
      ..setEndpoint('https://nyc.cloud.appwrite.io/v1')
      ..setProject('6929cfe0000789817066');
    databases = Databases(client);
    account = Account(client);
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await account.get();
      setState(() {
        userId = user.$id;
      });
      _loadMyProperties();
    } catch (e) {
      print('Error loading user: $e');
      setState(() => _isLoadingProperties = false);
    }
  }

  Future<void> _loadMyProperties() async {
    if (userId == null) return;
    
    setState(() => _isLoadingProperties = true);
    
    try {
      final propertiesResponse = await databases.listDocuments(
        databaseId: '6929e1e300094da69676',
        collectionId: 'properties',
        queries: [
          Query.equal('ownerId', userId!),
        ],
      );

      setState(() {
        myProperties = propertiesResponse.documents
            .map((doc) => {'id': doc.$id, ...doc.data})
            .toList();
        _isLoadingProperties = false;
      });
    } catch (e) {
      print('Error loading properties: $e');
      setState(() => _isLoadingProperties = false);
    }
  }

  Future<void> _deleteProperty(String propertyId, String propertyTitle) async {
    // Confirmation avant suppression
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        title: const Text(
          'Confirmer la suppression',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "$propertyTitle" ?',
          style: const TextStyle(color: Color(0xFFB0B8C1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await databases.deleteDocument(
        databaseId: '6929e1e300094da69676',
        collectionId: 'properties',
        documentId: propertyId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propriété supprimée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMyProperties();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addProperty() async {
    if (!_formKey.currentState!.validate()) return;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non connecté. Veuillez vous connecter.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await databases.createDocument(
        databaseId: '6929e1e300094da69676',
        collectionId: 'properties',
        documentId: ID.unique(),
        data: {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'type': _selectedType,
          'prix': double.parse(_priceController.text),
          'localisation': _locationController.text.trim(),
          'lat': double.parse(_latController.text),
          'lng': double.parse(_lngController.text),
          'imageUrl': _imageUrlController.text.trim().isNotEmpty 
              ? _imageUrlController.text.trim()
              : 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
          'ownerId': userId,
        },
      );

      if (mounted) {
        // Réinitialiser le formulaire
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _locationController.clear();
        _latController.clear();
        _lngController.clear();
        _imageUrlController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propriété ajoutée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Recharger les propriétés
        _loadMyProperties();
        
        // Passer à l'onglet "Mes propriétés"
        setState(() => _selectedTab = 1);
      }
    } on AppwriteException catch (e) {
      if (mounted) {
        String errorMessage = 'Erreur lors de l\'ajout';
        
        if (e.message?.contains('unauthorized') ?? false) {
          errorMessage = 'Erreur: Permissions insuffisantes. Veuillez configurer les permissions dans Appwrite Console.';
        } else if (e.message != null) {
          errorMessage = 'Erreur: ${e.message}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B263B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'Gérer mes propriétés',
          style: TextStyle(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: const Color(0xFF1B263B),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 0 
                                ? const Color(0xFFD4AF37) 
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'Ajouter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 0 
                              ? const Color(0xFFD4AF37) 
                              : Colors.grey,
                          fontSize: 16,
                          fontWeight: _selectedTab == 0 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 1 
                                ? const Color(0xFFD4AF37) 
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'Mes propriétés',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 1 
                              ? const Color(0xFFD4AF37) 
                              : Colors.grey,
                          fontSize: 16,
                          fontWeight: _selectedTab == 1 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _selectedTab == 0 ? _buildAddPropertyTab() : _buildMyPropertiesTab(),
    );
  }

  Widget _buildAddPropertyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            const Text(
              'Titre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Ex: Villa moderne vue mer'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Titre requis' : null,
            ),

            const SizedBox(height: 20),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: _inputDecoration('Décrivez votre propriété...'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Description requise' : null,
            ),

            const SizedBox(height: 20),

            // Type
            const Text(
              'Type de propriété',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2C3E50),
                ),
              ),
              child: DropdownButton<String>(
                value: _selectedType,
                isExpanded: true,
                dropdownColor: const Color(0xFF1B263B),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
                items: _propertyTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedType = newValue);
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // Prix
            const Text(
              'Prix (DT)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Ex: 450000'),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Prix requis';
                if (double.tryParse(value!) == null) return 'Prix invalide';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Localisation
            const Text(
              'Localisation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Ex: La Marsa, Tunis'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Localisation requise' : null,
            ),

            const SizedBox(height: 20),

            // URL de l'image
            const Text(
              'URL de l\'image (optionnel)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _imageUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('https://example.com/image.jpg'),
            ),

            const SizedBox(height: 20),

            // Coordonnées GPS
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Latitude',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _latController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration('36.8065'),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Requis';
                          if (double.tryParse(value!) == null) return 'Invalide';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Longitude',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lngController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration('10.1815'),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Requis';
                          if (double.tryParse(value!) == null) return 'Invalide';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Bouton Ajouter
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addProperty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Ajouter la propriété',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPropertiesTab() {
    if (_isLoadingProperties) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      );
    }

    if (myProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_outlined, size: 80, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'Aucune propriété',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre première propriété',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myProperties.length,
      itemBuilder: (context, index) {
        final property = myProperties[index];
        return Card(
          color: const Color(0xFF1B263B),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    property['imageUrl'] ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[800],
                        child: const Icon(Icons.home, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property['type'] ?? '',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${property['prix']?.toStringAsFixed(0) ?? '0'} DT',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteProperty(
                    property['id'],
                    property['title'] ?? 'cette propriété',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFFB0B8C1).withOpacity(0.5)),
      filled: true,
      fillColor: const Color(0xFF1B263B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C3E50)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C3E50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}