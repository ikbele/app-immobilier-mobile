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
  int _selectedTab = 0;

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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ).createShader(bounds),
          child: const Text(
            'Confirmer la suppression',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "$propertyTitle" ?',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
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
          SnackBar(
            content: const Text('Propriété supprimée avec succès !'),
            backgroundColor: const Color(0xFFFFD700),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _addProperty() async {
    if (!_formKey.currentState!.validate()) return;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Utilisateur non connecté. Veuillez vous connecter.'),
          backgroundColor: const Color(0xFFFFA500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _locationController.clear();
        _latController.clear();
        _lngController.clear();
        _imageUrlController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Propriété ajoutée avec succès !'),
            backgroundColor: const Color(0xFFFFD700),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        _loadMyProperties();
        setState(() => _selectedTab = 1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ).createShader(bounds),
          child: const Text(
            'Gérer mes propriétés',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: _selectedTab == 0
                            ? const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _selectedTab == 0
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        'Ajouter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 0 ? Colors.black : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: _selectedTab == 1
                            ? const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _selectedTab == 1
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        'Mes propriétés',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 1 ? Colors.black : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
            _buildSectionTitle('Titre'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hint: 'Ex: Villa moderne vue mer',
              validator: (value) => value?.isEmpty ?? true ? 'Titre requis' : null,
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle('Description'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Décrivez votre propriété...',
              maxLines: 4,
              validator: (value) => value?.isEmpty ?? true ? 'Description requise' : null,
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle('Type de propriété'),
            const SizedBox(height: 8),
            _buildTypeSelector(),
            const SizedBox(height: 20),
            
            _buildSectionTitle('Prix (DT)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _priceController,
              hint: 'Ex: 450000',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Prix requis';
                if (double.tryParse(value!) == null) return 'Prix invalide';
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle('Localisation'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _locationController,
              hint: 'Ex: La Marsa, Tunis',
              validator: (value) => value?.isEmpty ?? true ? 'Localisation requise' : null,
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle('URL de l\'image (optionnel)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _imageUrlController,
              hint: 'https://example.com/image.jpg',
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Latitude'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _latController,
                        hint: '36.8065',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      _buildSectionTitle('Longitude'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _lngController,
                        hint: '10.1815',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            
            _buildPremiumButton(
              text: 'Ajouter la propriété',
              onPressed: _isLoading ? null : _addProperty,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPropertiesTab() {
    if (_isLoadingProperties) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.5),
                blurRadius: 30,
              ),
            ],
          ),
          child: const CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (myProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.2),
                    const Color(0xFFFFA500).withOpacity(0.2),
                  ],
                ),
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 80,
                color: Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ).createShader(bounds),
              child: const Text(
                'Aucune propriété',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ajoutez votre première propriété',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white54,
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
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                      ),
                    ),
                    child: Image.network(
                      property['imageUrl'] ?? '',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90,
                          height: 90,
                          color: const Color(0xFF1A1A1A),
                          child: const Icon(
                            Icons.home,
                            color: Color(0xFFFFD700),
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFD700).withOpacity(0.2),
                              const Color(0xFFFFA500).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          property['type'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ).createShader(bounds),
                        child: Text(
                          '${property['prix']?.toStringAsFixed(0) ?? '0'} DT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
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

  Widget _buildSectionTitle(String title) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      ).createShader(bounds),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
        value: _selectedType,
        isExpanded: true,
        dropdownColor: const Color(0xFF2A2A2A),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        underline: const SizedBox(),
        icon: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ).createShader(bounds),
          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
        ),
        items: _propertyTypes.map((String type) {
          return DropdownMenuItem(
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
    );
  }

  Widget _buildPremiumButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
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