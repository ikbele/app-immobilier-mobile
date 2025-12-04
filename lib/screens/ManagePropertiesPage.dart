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
      setState(() => userId = user.$id);
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
        title: const Text("Confirmer la suppression", style: TextStyle(color: Colors.white)),
        content: Text(
          'Supprimer "$title" ?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
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
            content: Text("Propriété supprimée !"),
            backgroundColor: Color(0xFFFFD700),
          ),
        );
        _loadMyProperties();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ---------------------------------------------------------------
  // --------------------  AJOUT PROPERTY  -------------------------
  // ---------------------------------------------------------------
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
      // 🔥 On récupère maintenant le nom de l'utilisateur !!
      final user = await account.get();
      final userName = user.name ?? user.email ?? 'Utilisateur';

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
          'ownerName': userName, // ✅ AJOUTÉ !
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
            content: Text("Propriété ajoutée !"),
            backgroundColor: Color(0xFFFFD700),
          ),
        );

        _loadMyProperties();
        setState(() => _selectedTab = 1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text("Gérer mes propriétés", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: _selectedTab == 0 ? _buildAddTab() : _buildListTab(),
      bottomNavigationBar: _buildTabs(),
    );
  }

  Widget _buildTabs() {
    return BottomNavigationBar(
      currentIndex: _selectedTab,
      backgroundColor: const Color(0xFF2A2A2A),
      selectedItemColor: const Color(0xFFFFD700),
      unselectedItemColor: Colors.grey,
      onTap: (i) => setState(() => _selectedTab = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.add), label: "Ajouter"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Mes propriétés"),
      ],
    );
  }

  // ---------------------- ADD TAB ---------------------
  Widget _buildAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildInput("Titre", _titleController),
            const SizedBox(height: 12),
            _buildInput("Description", _descriptionController, maxLines: 4),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              dropdownColor: const Color(0xFF1A1A1A),
              value: _selectedType,
              items: _propertyTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
              decoration: _inputDecoration("Type"),
            ),
            const SizedBox(height: 12),
            _buildInput("Prix", _priceController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildInput("Localisation", _locationController),
            const SizedBox(height: 12),
            _buildInput("Latitude", _latController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildInput("Longitude", _lngController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildInput("Image URL (optionnel)", _imageUrlController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _addProperty,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text("Ajouter", style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------- LIST TAB ---------------------
  Widget _buildListTab() {
    if (_isLoadingProperties) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }

    if (myProperties.isEmpty) {
      return const Center(
        child: Text("Aucune propriété", style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: myProperties.length,
      itemBuilder: (context, index) {
        final p = myProperties[index];

        return Card(
          color: const Color(0xFF2A2A2A),
          child: ListTile(
            leading: Image.network(
              p["imageUrl"],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(p["title"], style: const TextStyle(color: Colors.white)),
            subtitle: Text("${p["prix"]} DT", style: const TextStyle(color: Colors.white70)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProperty(p["id"], p["title"]),
            ),
          ),
        );
      },
    );
  }

  // ---------------- INPUT + STYLE ----------------
  Widget _buildInput(String label, TextEditingController c, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
      validator: (v) => (v == null || v.isEmpty) ? "Champ requis" : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
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
