import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth
import 'login_page.dart'; // Importando a página de login
import 'firebase_options.dart'; // Importa as opções geradas
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa o Firebase com opções específicas para cada plataforma
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    // Caso haja algum erro durante a inicialização
    print('Erro ao inicializar o Firebase: $e');
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alerta Rural',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey;
              }
              return Colors.green;
            },
          ),
          trackColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey.shade300;
              }
              return Colors.green.shade300;
            },
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green.shade700),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700),
          ),
          labelStyle: const TextStyle(color: Colors.green),
          hintStyle: TextStyle(color: Colors.green.shade300),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Erro ao inicializar o Firebase. Tente novamente mais tarde.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final MaskedTextController _phoneController =
      MaskedTextController(mask: '(00)000000000');
  final MaskedTextController _emergencyPhoneController =
      MaskedTextController(mask: '(00)000000000');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _propertyNameController =
      TextEditingController();
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
    // Use snapshots para escutar as mudanças em tempo real
    _firestore.collection('users').snapshots().listen((snapshot) {
      final List<UserData> loadedUsers = snapshot.docs.map((doc) {
        return UserData.fromFirestore(doc);
      }).toList();

      setState(() {
        users.clear(); // Limpa a lista antes de adicionar novos usuários
        users.addAll(loadedUsers); // Adiciona os usuários atualizados
      });
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
                  title: Text(user.property_name),
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
                      IconButton(
                        icon: const Icon(Icons.lock_reset),
                        onPressed: () => _resetPassword(user.email),
                      ),
                      Switch(
                        value: user.isMasterUser,
                        onChanged: (value) => _toggleMasterUserStatus(index, value),
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

  Future<void> _toggleMasterUserStatus(int index, bool isMasterUser) async {
  final user = users[index];
  
  // Verifica se o usuário logado é um master e está tentando alterar seu próprio estado
  if (user.userId == _auth.currentUser!.uid && isMasterUser) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Você não pode alterar seu próprio estado de usuário master.'),
      ),
    );
    return; // Não faz nada se for o próprio usuário master
  }

  try {
    // Atualiza o status de master no Firestore
    await _firestore.collection('users').doc(user.userId).update({
      'isMasterUser': isMasterUser,
    });

    setState(() {
      users[index].isMasterUser = isMasterUser;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuário ${isMasterUser ? 'promovido a usuário master' : 'removido de usuário master'} com sucesso!'),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao atualizar status: $e')),
    );
  }
}

  Future<void> _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de redefinição de senha enviado!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar email de redefinição: $e')),
      );
    }
  }

  void _editUser(int index) {
    final user = users[index];
    _nameController.text = user.name;
    _phoneController.text = user.phone;
    _emergencyPhoneController.text = user.emergency_phone;
    _emailController.text = user.email;
    _propertyNameController.text = user.property_name;
    _ruralCodeController.text = user.rural_code;
    _geolocationController.text = user.location;
    _editingIndex = index;
    _isMasterUser = user.isMasterUser;

    _showUserDialog(user: user);
  }

  Future<void> _showUserDialog({UserData? user}) {
    if (user != null) {
      _editingIndex = users.indexOf(user);
      _isMasterUser = user.isMasterUser;
    } else {
      _clearFields();
      _editingIndex = null;
      _isMasterUser = false;
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Adicionar Usuário' : 'Editar Usuário'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                ),
                TextField(
                  controller: _emergencyPhoneController,
                  decoration: const InputDecoration(labelText: 'Telefone de Emergência'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _propertyNameController,
                  decoration: const InputDecoration(labelText: 'Nome da Propriedade'),
                ),
                TextField(
                  controller: _ruralCodeController,
                  decoration: const InputDecoration(labelText: 'Código Rural'),
                ),
                TextField(
                  controller: _geolocationController,
                  decoration: const InputDecoration(labelText: 'Geolocalização'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Usuário Master:'),
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
            ElevatedButton(
              onPressed: () async {
                if (await _saveUser(user)) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _saveUser(UserData? user) async {
    final name = _nameController.text;
    final phone = _phoneController.text;
    final emergencyPhone = _emergencyPhoneController.text;
    final email = _emailController.text;
    final propertyName = _propertyNameController.text;
    final ruralCode = _ruralCodeController.text;
    final geolocation = _geolocationController.text;

    if (name.isEmpty || phone.isEmpty || email.isEmpty || propertyName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
      return false;
    }

    try {
      if (user == null) {
        // Se não for um usuário existente, cria um novo
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(email: email, password: 'usuario123');

        // Salva a ID do usuário no Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'phone': phone,
          'emergency_phone': emergencyPhone,
          'email': email,
          'property_name': propertyName,
          'rural_code': ruralCode,
          'location': geolocation,
          'isMasterUser': _isMasterUser,
          'userId': userCredential.user!.uid, // Salva a ID do usuário
        });
      } else {
        // Atualiza o usuário existente
        await _firestore.collection('users').doc(user.userId).update({
          'name': name,
          'phone': phone,
          'emergency_phone': emergencyPhone,
          'email': email,
          'property_name': propertyName,
          'rural_code': ruralCode,
          'location': geolocation,
          'isMasterUser': _isMasterUser,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário salvo com sucesso!')),
      );

      // Atualiza a lista de usuários
      if (user == null) {
        users.add(UserData(
          userId: _auth.currentUser!.uid, // Atualiza a lista com a nova ID
          name: name,
          phone: phone,
          emergency_phone: emergencyPhone,
          email: email,
          property_name: propertyName,
          rural_code: ruralCode,
          location: geolocation,
          isMasterUser: _isMasterUser,
        ));
      } else {
        users[_editingIndex!] = UserData(
          userId: user.userId,
          name: name,
          phone: phone,
          emergency_phone: emergencyPhone,
          email: email,
          property_name: propertyName,
          rural_code: ruralCode,
          location: geolocation,
          isMasterUser: _isMasterUser,
        );
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar usuário: $e')),
      );
      return false;
    }
  }

  Future<void> _confirmDeleteUser(int index) async {
    final user = users[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Você tem certeza que deseja excluir este usuário?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('users').doc(user.userId).delete();
        setState(() {
          users.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário excluído com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir usuário: $e')),
        );
      }
    }
  }

  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _emergencyPhoneController.clear();
    _emailController.clear();
    _propertyNameController.clear();
    _ruralCodeController.clear();
    _geolocationController.clear();
  }
}

class UserData {
  final String userId;
  final String name;
  final String phone;
  final String emergency_phone;
  final String email;
  final String property_name;
  final String rural_code;
  final String location;
  bool isMasterUser;

  UserData({
    required this.userId,
    required this.name,
    required this.phone,
    required this.emergency_phone,
    required this.email,
    required this.property_name,
    required this.rural_code,
    required this.location,
    required this.isMasterUser,
  });

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    return UserData(
      userId: doc.id,
      name: doc['name'],
      phone: doc['phone'],
      emergency_phone: doc['emergency_phone'],
      email: doc['email'],
      property_name: doc['property_name'],
      rural_code: doc['rural_code'],
      location: doc['location'],
      isMasterUser: doc['isMasterUser'] ?? false,
    );
  }
}
