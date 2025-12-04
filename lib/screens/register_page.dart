import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _prenomController = TextEditingController(); // Ajout du prénom
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late Client client;
  late Account account;
  late Databases databases;

  @override
  void initState() {
    super.initState();
    client = Client()
      ..setEndpoint('https://nyc.cloud.appwrite.io/v1')
      ..setProject('6929cfe0000789817066');
    account = Account(client);
    databases = Databases(client);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Créer l'utilisateur dans Appwrite Auth
      final user = await account.create(
        userId: ID.unique(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: '${_prenomController.text.trim()} ${_nameController.text.trim()}', // Prénom + Nom
      );

      // Créer la session
      await account.createEmailPasswordSession(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Sauvegarder les infos supplémentaires dans la collection users
      try {
        await databases.createDocument(
          databaseId: '6929e1e300094da69676',
          collectionId: 'users',
          documentId: user.$id, // Utiliser l'ID utilisateur comme ID du document
          data: {
            'userId': user.$id,
            'name': _nameController.text.trim(),
            'prenom': _prenomController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
          },
        );
      } catch (e) {
        print('Error saving user data: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie !'),
            backgroundColor: Color(0xFFFFD700),
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on AppwriteException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Erreur lors de l\'inscription'),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_work,
                        size: 50,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 30),

                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ).createShader(bounds),
                      child: const Text(
                        "Créer un compte",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Rejoignez HouseStyle Premium",
                      style: TextStyle(
                        color: Color(0xFFB0B8C1),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildTextField(_prenomController, 'Prénom', Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildTextField(_nameController, 'Nom', Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, 'Email', Icons.email, isEmail: true),
                    const SizedBox(height: 16),
                    _buildTextField(_phoneController, 'Téléphone (optionnel)', Icons.phone, isPhone: true, isRequired: false),
                    const SizedBox(height: 16),
                    _buildPasswordField(_passwordController, 'Mot de passe', _obscurePassword, () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    }),
                    const SizedBox(height: 16),
                    _buildPasswordField(_confirmPasswordController, 'Confirmer', _obscureConfirmPassword, () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    }, isConfirm: true),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF1A1A1A),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Déjà un compte ? ",
                          style: TextStyle(color: Color(0xFFB0B8C1)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ).createShader(bounds),
                            child: const Text(
                              "Se connecter",
                              style: TextStyle(
                                color: Colors.white,
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isEmail = false,
    bool isPhone = false,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : (isPhone ? TextInputType.phone : TextInputType.text),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFB0B8C1)),
        prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) return 'Requis';
        if (isEmail && value != null && value.isNotEmpty && !value.contains('@')) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    bool obscure,
    VoidCallback onToggle, {
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFB0B8C1)),
        prefixIcon: Icon(
          isConfirm ? Icons.lock_outline : Icons.lock,
          color: const Color(0xFFFFD700),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFFFFD700),
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Requis';
        if (!isConfirm && value.length < 8) return 'Min 8 caractères';
        if (isConfirm && value != _passwordController.text) {
          return 'Mots de passe non identiques';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}