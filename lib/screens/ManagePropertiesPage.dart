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
  String? userName;
  String? userEmail;
  List<Map<String, dynamic>> myProperties = [];
  int _selectedTab = 0;

  // Pour la modification
  String? _editingPropertyId;
  bool _isEditMode = false;

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
        userName = user.name ?? user.email ?? 'Utilisateur';
        userEmail = user.email;
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
      final res = await databases.listDocuments(
        databaseId: '6929e1e300094da69676',
        collectionId: 'properties',
        queries: [Query.equal('ownerId', userId!)],
      );

      setState(() {
        myProperties = res.documents.map((doc) => {'id': doc.$id, ...doc.data}).toList();
        _isLoadingProperties = false;
      });
    } catch (e) {
      print('Error loading properties: $e');
      setState(() => _isLoadingProperties = false);
    }
  }

  Future<void> _deleteProperty(String id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Confirmer la suppression",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Êtes-vous sûr de vouloir supprimer cette propriété ?',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cette action est irréversible.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await databases.deleteDocument(
        databaseId: '6929e1e300094da69676',
        collectionId: 'properties',
        documentId: id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.black),
                SizedBox(width: 8),
                Text("Propriété supprimée avec succès !"),
              ],
            ),
            backgroundColor: Color(0xFFFFD700),
          ),
        );
        _loadMyProperties();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la suppression : $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startEditProperty(Map<String, dynamic> property) {
    setState(() {
      _isEditMode = true;
      _editingPropertyId = property['id'];
      _titleController.text = property['title'] ?? '';
      _descriptionController.text = property['description'] ?? '';
      _priceController.text = property['prix']?.toString() ?? '';
      _locationController.text = property['localisation'] ?? '';
      _latController.text = property['lat']?.toString() ?? '';
      _lngController.text = property['lng']?.toString() ?? '';
      _imageUrlController.text = property['imageUrl'] ?? '';
      _selectedType = property['type'] ?? 'Villa';
      _selectedTab = 0; // Aller à l'onglet formulaire
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _editingPropertyId = null;
      _formKey.currentState?.reset();
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _locationController.clear();
      _latController.clear();
      _lngController.clear();
      _imageUrlController.clear();
      _selectedType = 'Villa';
    });
  }

  Future<void> _updateProperty() async {
    if (!_formKey.currentState!.validate()) return;
    if (_editingPropertyId == null) return;

    setState(() => _isLoading = true);

    try {
      await databases.updateDocument(
        databaseId: '6929e1e300094da69676',
        collectionId: 'properties',
        documentId: _editingPropertyId!,
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
          'ownerName': userName,
          'ownerEmail': userEmail,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.black),
                SizedBox(width: 8),
                Text("Propriété modifiée avec succès !"),
              ],
            ),
            backgroundColor: Color(0xFFFFD700),
          ),
        );

        _cancelEdit();
        _loadMyProperties();
        setState(() => _selectedTab = 1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la modification : $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addProperty() async {
    if (!_formKey.currentState!.validate()) return;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Utilisateur non connecté."),
          backgroundColor: Color(0xFFFFA500),
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
          'ownerName': userName,
          'ownerEmail': userEmail,
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
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.black),
                SizedBox(width: 8),
                Text("Propriété ajoutée avec succès !"),
              ],
            ),
            backgroundColor: Color(0xFFFFD700),
          ),
        );

        _loadMyProperties();
        setState(() => _selectedTab = 1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de l'ajout : $e"),
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
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2A2A2A),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ).createShader(bounds),
          child: Text(
            _isEditMode ? "Modifier la propriété" : "Gérer mes propriétés",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () {
            if (_isEditMode) {
              _cancelEdit();
            } else {
              Navigator.pop(context, true);
            }
          },
        ),
        actions: _isEditMode
            ? [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: _cancelEdit,
                  tooltip: 'Annuler',
                ),
              ]
            : null,
      ),
      body: _selectedTab == 0 ? _buildFormTab() : _buildListTab(),
      bottomNavigationBar: _buildTabs(),
    );
  }

  Widget _buildTabs() {
    return BottomNavigationBar(
      currentIndex: _selectedTab,
      backgroundColor: const Color(0xFF2A2A2A),
      selectedItemColor: const Color(0xFFFFD700),
      unselectedItemColor: Colors.grey,
      onTap: (i) {
        if (_isEditMode && i == 1) {
          _cancelEdit();
        }
        setState(() => _selectedTab = i);
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(_isEditMode ? Icons.edit : Icons.add),
          label: _isEditMode ? "Modifier" : "Ajouter",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Mes propriétés",
        ),
      ],
    );
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditMode)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.2),
                      const Color(0xFFFFA500).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit, color: Color(0xFFFFD700)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Mode modification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildInput("Titre", _titleController),
            const SizedBox(height: 16),
            _buildInput("Description", _descriptionController, maxLines: 4),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF2A2A2A),
              value: _selectedType,
              items: _propertyTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
              decoration: _inputDecoration("Type de propriété"),
            ),
            const SizedBox(height: 16),
            _buildInput("Prix (DT)", _priceController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildInput("Localisation", _locationController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInput("Latitude", _latController, keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInput("Longitude", _lngController, keyboardType: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInput("URL de l'image (optionnel)", _imageUrlController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_isEditMode ? _updateProperty : _addProperty),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_isEditMode ? Icons.check : Icons.add),
                          const SizedBox(width: 8),
                          Text(
                            _isEditMode ? "Modifier la propriété" : "Ajouter la propriété",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (_isEditMode) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _cancelEdit,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListTab() {
    if (_isLoadingProperties) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      );
    }

    if (myProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.home_outlined,
                size: 60,
                color: Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Aucune propriété",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Commencez par ajouter votre première propriété",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() => _selectedTab = 0),
              icon: const Icon(Icons.add),
              label: const Text("Ajouter une propriété"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
        return _buildPropertyCard(property);
      },
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
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
            blurRadius: 10,
            spreadRadius: 1,
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
            child: Image.network(
              property['imageUrl'] ?? 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: const Color(0xFF3A3A3A),
                  child: const Center(
                    child: Icon(Icons.home, size: 60, color: Color(0xFFFFD700)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property['title'] ?? 'Sans titre',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        property['type'] ?? 'Villa',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Color(0xFFFFD700)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property['localisation'] ?? 'Non spécifié',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "${property['prix'] ?? 0} DT",
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _startEditProperty(property),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Modifier"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteProperty(property['id'], property['title']),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text("Supprimer"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Ce champ est requis";
        }
        if (label.contains("Prix") || label.contains("Latitude") || label.contains("Longitude")) {
          if (double.tryParse(value) == null) {
            return "Veuillez entrer un nombre valide";
          }
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
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