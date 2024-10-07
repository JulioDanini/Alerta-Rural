import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';


class UserManagementPage extends StatefulWidget {
  final bool isMasterUser;

  const UserManagementPage({Key? key, required this.isMasterUser})
      : super(key: key);

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final List<User> users = [];
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
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
                      IconButton(
                        icon: const Icon(Icons.lock_reset),
                        onPressed: () => _resetPassword(index),
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
                      backgroundColor: Colors.green, // Cor do botão para verde
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

  void _resetPassword(int index) {
    setState(() {
      users[index].password = '123';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha redefinida para padrão: 123')),
    );
  }


  void _showUserDialog({User? user}) {
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

  void _addUser() {
    final validationErrors = _validateFields();
    if (validationErrors.isEmpty) {
      setState(() {
        users.add(User(
          name: _nameController.text,
          phone: _phoneController.text,
          emergencyPhone: _emergencyPhoneController.text,
          email: _emailController.text,
          userId: _userIdController.text,
          propertyName: _propertyNameController.text,
          ruralCode: _ruralCodeController.text,
          geolocation: _geolocationController.text,
          password: '123',
          isMasterUser: _isMasterUser,
          isEnabled: true,
        ));
        _clearFields();
      });
    } else {
      _showErrorDialog(validationErrors);
    }
  }

  void _updateUser() {
    final validationErrors = _validateFields();
    if (validationErrors.isEmpty) {
      setState(() {
        if (_editingIndex != null) {
          users[_editingIndex!] = User(
            name: _nameController.text,
            phone: _phoneController.text,
            emergencyPhone: _emergencyPhoneController.text,
            email: _emailController.text,
            userId: _userIdController.text,
            propertyName: _propertyNameController.text,
            ruralCode: _ruralCodeController.text,
            geolocation: _geolocationController.text,
            password: users[_editingIndex!].password,
            isMasterUser: _isMasterUser,
            isEnabled: users[_editingIndex!].isEnabled,
          );
          _clearFields();
          _editingIndex = null;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Dados do usuário alterados com sucesso!')),
          );
        }
      });
    } else {
      _showErrorDialog(validationErrors);
    }
  }

  void _confirmDeleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmação de Exclusão'),
          content:
              const Text('Você tem certeza que deseja excluir este usuário?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _disableUser(index);
                Navigator.of(context).pop();
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(List<String> messages) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: messages.map((message) => Text(message)).toList(),
            ),
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

  bool _validateEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  List<String> _validateFields() {
    List<String> validationErrors = [];

    if (_nameController.text.isEmpty) {
      validationErrors.add('O nome do usuário é obrigatório.');
    }
    if (_phoneController.text.isEmpty) {
      validationErrors.add('O telefone é obrigatório.');
    }
    if (_emailController.text.isEmpty ||
        !_validateEmail(_emailController.text)) {
      validationErrors.add('O e-mail é inválido.');
    }
    if (_userIdController.text.isEmpty) {
      validationErrors.add('O ID do usuário é obrigatório.');
    }
    if (_propertyNameController.text.isEmpty) {
      validationErrors.add('O nome da propriedade é obrigatório.');
    }
    if (_ruralCodeController.text.isEmpty) {
      validationErrors.add('O código rural é obrigatório.');
    }
    if (_geolocationController.text.isEmpty) {
      validationErrors.add('A geolocalização é obrigatória.');
    }

    return validationErrors;
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

  void _disableUser(int index) {
    setState(() {
      users.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário excluído com sucesso!')),
    );
  }

  void _toggleUserStatus(int index) {
    setState(() {
      users[index].isEnabled = !users[index].isEnabled;

      // Exibir mensagem informando o novo status
      final status = users[index].isEnabled ? 'habilitado' : 'desabilitado';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário ${users[index].name} foi $status.')),
      );
    });
  }

  void _editUser(int index) {
    _showUserDialog(user: users[index]);
  }
}

class User {
  String name;
  String phone;
  String emergencyPhone;
  String email;
  String userId;
  String propertyName;
  String ruralCode;
  String geolocation;
  String password;
  bool isMasterUser;
  bool isEnabled;

  User({
    required this.name,
    required this.phone,
    required this.emergencyPhone,
    required this.email,
    required this.userId,
    required this.propertyName,
    required this.ruralCode,
    required this.geolocation,
    required this.password,
    this.isMasterUser = false,
    this.isEnabled = true,
  });
}
