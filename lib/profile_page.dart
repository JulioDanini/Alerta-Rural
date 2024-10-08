import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final Function(String, String, String, String, String, String, String)
      onLocationSaved;

  const ProfilePage({super.key, required this.onLocationSaved});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _ruralCodeController = TextEditingController();
  final MaskedTextController _emergencyPhoneController = MaskedTextController(mask: '(00)000000000');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    if (currentUser != null) {
      _emailController.text = currentUser!.email!;
      _idController.text = currentUser!.uid;
      _loadUserProfileByEmail(_emailController.text); // Carrega o perfil do usuário pelo email
    }
  }

  // Carrega o perfil do usuário pelo email cadastrado
  Future<void> _loadUserProfileByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs[0].data() as Map<String, dynamic>;
        setState(() {
          _locationController.text = data['location'] ?? '';
          _propertyNameController.text = data['property_name'] ?? '';
          _ruralCodeController.text = data['rural_code'] ?? '';
          _emergencyPhoneController.text = data['emergency_phone'] ?? '';
          _nameController.text = data['name'] ?? '';
        });
      } else {
        print('Nenhum usuário encontrado com o email $email');
      }
    } catch (e) {
      print('Erro ao carregar o perfil: $e');
    }
  }

  Future<void> _saveUserProfile() async {
    if (_validatePhoneNumber(_emergencyPhoneController.text)) {
      try {
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'location': _locationController.text,
          'property_name': _propertyNameController.text,
          'rural_code': _ruralCodeController.text,
          'emergency_phone': _emergencyPhoneController.text,
          'name': _nameController.text,
          'email': _emailController.text,
          'user_id': _idController.text,
        });

        widget.onLocationSaved(
          _locationController.text,
          _propertyNameController.text,
          _ruralCodeController.text,
          _emergencyPhoneController.text,
          _nameController.text,
          _idController.text,
          _emailController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil salvo com sucesso!')),
        );
      } catch (e) {
        print('Erro ao salvar perfil: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar o perfil')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um número de telefone válido')),
      );
    }
  }

  bool _validatePhoneNumber(String phone) {
    final RegExp phoneExp = RegExp(r'^\(\d{2}\)\d{8,9}$');     
    return phoneExp.hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do Usuário'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emergencyPhoneController,
              decoration: InputDecoration(
                labelText: 'Telefone de Emergência',
                errorText: _validatePhoneNumber(_emergencyPhoneController.text)
                    ? null
                    : 'Número de telefone inválido',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('E-mail'),
              subtitle: Text(_emailController.text),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Nome da Propriedade'),
              subtitle: Text(_propertyNameController.text),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Código Rural do Município'),
              subtitle: Text(_ruralCodeController.text),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Geolocalização Plus Codes'),
              subtitle: Text(_locationController.text),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('ID do Usuário'),
              subtitle: Text(_idController.text),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveUserProfile,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
