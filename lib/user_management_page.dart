import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alerta Rural',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: UserManagementPage(isMasterUser: true), // Tela de Gerenciamento
    );
  }
}

class UserManagementPage extends StatefulWidget {
  final bool isMasterUser;

  const UserManagementPage({Key? key, required this.isMasterUser})
      : super(key: key);

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final List<UserData> users = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final MaskedTextController _phoneController =
      MaskedTextController(mask: '(00)000000000');
  final MaskedTextController _emergencyPhoneController =
      MaskedTextController(mask: '(00)000000000');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _ruralCodeController = TextEditingController();
  final TextEditingController _geolocationController = TextEditingController();

  int? _editingIndex;
  bool _isMasterUser = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final QuerySnapshot snapshot = await _firestore.collection('users').get();
    final List<UserData> loadedUsers = snapshot.docs.map((doc) {
      return UserData.fromFirestore(doc);
    }).toList();

    setState(() {
      users.addAll(loadedUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Gerenciamento de Usuários'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.propertyName),
                  subtitle:
                      Text('Usuário: ${user.name} - Telefone: ${user.phone}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editUser(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteUser(index),
                      ),
                      Switch(
                        value: user.isEnabled,
                        onChanged: (value) => _toggleUserStatus(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showUserDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Adicionar Usuário'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _resetPassword(int index) async {
    final user = users[index];
    await auth.FirebaseAuth.instance
        .sendPasswordResetEmail(email: user.email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('E-mail de redefinição de senha enviado.')),
    );
  }

  void _showUserDialog({UserData? user}) {
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _emergencyPhoneController.text = user.emergencyPhone;
      _emailController.text = user.email;
      _userIdController.text = user.userId;
      _propertyNameController.text = user.propertyName;
      _ruralCodeController.text = user.ruralCode;
      _geolocationController.text = user.geolocation;
      _editingIndex = users.indexOf(user);
      _isMasterUser = user.isMasterUser;
    } else {
      _clearFields();
      _editingIndex = null;
      _isMasterUser = false;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Adicionar Usuário' : 'Editar Usuário'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nome do Usuário'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                ),
                TextField(
                  controller: _emergencyPhoneController,
                  decoration: const InputDecoration(
                      labelText: 'Telefone de Emergência'),
                ),
                TextField(
                  controller: _emailController,
                  decoration:
                      const InputDecoration(labelText: 'E-mail do Usuário'),
                ),
                TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(labelText: 'ID do Usuário'),
                ),
                TextField(
                  controller: _propertyNameController,
                  decoration:
                      const InputDecoration(labelText: 'Nome da Propriedade'),
                ),
                TextField(
                  controller: _ruralCodeController,
                  decoration: const InputDecoration(labelText: 'Código Rural'),
                ),
                TextField(
                  controller: _geolocationController,
                  decoration:
                      const InputDecoration(labelText: 'Geolocalização'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Usuário Master'),
                    Switch(
                      value: _isMasterUser,
                      onChanged: (value) {
                        setState(() {
                          _isMasterUser = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (user == null) {
                  _addUser();
                } else {
                  _updateUser();
                }
                Navigator.of(context).pop();
              },
              child: Text(user == null ? 'Adicionar' : 'Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addUser() async {
    final validationErrors = _validateFields();
    if (validationErrors.isEmpty) {
      try {
        final newUser = await auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text, password: '123456');
        final userDoc = _firestore.collection('users').doc(newUser.user!.uid);

        final userData = UserData(
          name: _nameController.text,
          phone: _phoneController.text,
          emergencyPhone: _emergencyPhoneController.text,
          email: _emailController.text,
          userId: _userIdController.text,
          propertyName: _propertyNameController.text,
          ruralCode: _ruralCodeController.text,
          geolocation: _geolocationController.text,
          isMasterUser: _isMasterUser,
          isEnabled: true,
        );

        await userDoc.set(userData.toFirestore());
        setState(() {
          users.add(userData);
        });

        _clearFields();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário adicionado com sucesso!')),
        );
      } catch (e) {
        _showErrorDialog([e.toString()]);
      }
    } else {
      _showErrorDialog(validationErrors);
    }
  }

  Future<void> _updateUser() async {
    final validationErrors = _validateFields();
    if (validationErrors.isEmpty) {
      setState(() {
        if (_editingIndex != null) {
          final user = users[_editingIndex!];
          final userDoc = _firestore.collection('users').doc(user.userId);
          final updatedUser = UserData(
            name: _nameController.text,
            phone: _phoneController.text,
            emergencyPhone: _emergencyPhoneController.text,
            email: _emailController.text,
            userId: _userIdController.text,
            propertyName: _propertyNameController.text,
            ruralCode: _ruralCodeController.text,
            geolocation: _geolocationController.text,
            isMasterUser: _isMasterUser,
            isEnabled: user.isEnabled,
          );

          users[_editingIndex!] = updatedUser;
          userDoc.set(updatedUser.toFirestore());
        }
        _clearFields();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário atualizado com sucesso!')),
        );
      });
    } else {
      _showErrorDialog(validationErrors);
    }
  }

  void _editUser(int index) {
    final user = users[index];
    _showUserDialog(user: user);
  }

  Future<void> _deleteUser(int index) async {
    final user = users[index];
    await _firestore.collection('users').doc(user.userId).delete();
    setState(() {
      users.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário removido com sucesso!')),
    );
  }

  void _confirmDeleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Usuário'),
          content: const Text('Tem certeza que deseja excluir este usuário?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteUser(index);
                Navigator.of(context).pop();
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _toggleUserStatus(int index) {
    setState(() {
      users[index].isEnabled = !users[index].isEnabled;
    });
  }

  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _emergencyPhoneController.clear();
    _emailController.clear();
    _userIdController.clear();
    _propertyNameController.clear();
    _ruralCodeController.clear();
    _geolocationController.clear();
  }

  List<String> _validateFields() {
    final errors = <String>[];

    if (_nameController.text.isEmpty) {
      errors.add('Nome é obrigatório.');
    }
    if (_phoneController.text.isEmpty) {
      errors.add('Telefone é obrigatório.');
    }
    if (_emergencyPhoneController.text.isEmpty) {
      errors.add('Telefone de emergência é obrigatório.');
    }
    if (_emailController.text.isEmpty) {
      errors.add('E-mail é obrigatório.');
    }

    return errors;
  }

  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: errors.map((e) => Text(e)).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class UserData {
  String name;
  String phone;
  String emergencyPhone;
  String email;
  String userId;
  String propertyName;
  String ruralCode;
  String geolocation;
  bool isMasterUser;
  bool isEnabled;

  UserData({
    required this.name,
    required this.phone,
    required this.emergencyPhone,
    required this.email,
    required this.userId,
    required this.propertyName,
    required this.ruralCode,
    required this.geolocation,
    required this.isMasterUser,
    required this.isEnabled,
  });

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserData(
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      emergencyPhone: data['emergencyPhone'] ?? '',
      email: data['email'] ?? '',
      userId: doc.id,
      propertyName: data['propertyName'] ?? '',
      ruralCode: data['ruralCode'] ?? '',
      geolocation: data['geolocation'] ?? '',
      isMasterUser: data['isMasterUser'] ?? false,
      isEnabled: data['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'emergencyPhone': emergencyPhone,
      'email': email,
      'propertyName': propertyName,
      'ruralCode': ruralCode,
      'geolocation': geolocation,
      'isMasterUser': isMasterUser,
      'isEnabled': isEnabled,
    };
  }
}
