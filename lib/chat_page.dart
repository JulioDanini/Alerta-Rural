import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Para o Timer
import 'package:cloud_firestore/cloud_firestore.dart'; // Importando o Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Importando a autenticação do Firebase
import 'profile_page.dart'; // Importando a página de perfil
import 'login_page.dart'; // Importando a página de login
import 'user_management_page.dart'; // Importando a página de gerenciamento de usuários

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.isMasterUser}) : super(key: key);

  final bool isMasterUser; // Propriedade para verificar se o usuário é master

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  String? userLocation; // Armazena a localização do usuário
  String? propertyName; // Nome da propriedade
  String? ruralCode; // Código rural
  String? emergencyPhone; // Telefones de emergência
  String username = ""; // Nome do usuário
  String userId = ""; // ID do usuário
  String email = ""; // E-mail do usuário
  bool _isAlertButtonEnabled = true; // Controle do botão de alerta
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instância do Firestore
  final User? currentUser = FirebaseAuth.instance.currentUser; // Usuário logado

  // Função para enviar mensagem
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      String timestamp = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      String message = '$username: ${_controller.text} \nEnviado em: $timestamp';

      _controller.clear();

      // Salva a mensagem no Firestore
      await _firestore.collection('messages').add({
        'message': message,
        'timestamp': DateTime.now(),
        'senderId': currentUser?.uid,
      });
    }
  }

  // Envia o alerta com as informações da propriedade
  void _sendAlert() async {
    String timestamp = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    String alertMessage = '''
🚨 ALERTA 🚨
Enviado por: $username
Propriedade: ${propertyName ?? "Desconhecida"}
Código Rural: ${ruralCode ?? "Desconhecido"}
Telefone de Emergência: ${emergencyPhone ?? "Não disponível"}
Localização(Plus Codes): ${userLocation ?? "Não disponível"}
Enviado em: $timestamp''';

    setState(() {
      _isAlertButtonEnabled = false;
    });

    // Salva o alerta no Firestore
    await _firestore.collection('messages').add({
      'message': alertMessage,
      'timestamp': DateTime.now(),
      'senderId': currentUser?.uid,
      'isAlert': true,
    });

    // Reinicia o botão após 3 minutos
    Timer(const Duration(minutes: 3), () {
      setState(() {
        _isAlertButtonEnabled = true;
      });
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alerta Enviado'),
          content: const Text('Alerta enviado com sucesso! Botão desabilitado por 3 minutos.'),
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

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToUserManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserManagementPage(isMasterUser: true)), // Passando true como exemplo
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Mensagens'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      onLocationSaved: (location, property, code, phone, name, id, email) {
                        // Armazena as informações do perfil
                        setState(() {
                          userLocation = location;
                          propertyName = property;
                          ruralCode = code;
                          emergencyPhone = phone;
                          username = name;
                          userId = id;
                          this.email = email;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            if (widget.isMasterUser) ...[
              ListTile(
                leading: const Icon(Icons.group_add),
                title: const Text('Cadastrar Usuários'),
                onTap: _navigateToUserManagement,
              ),
            ],
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    String messageText = messages[index]['message'];
                    // Verifica se a mensagem é um alerta (começa com "🚨 ALERTA 🚨")
                    if (messageText.startsWith('🚨 ALERTA 🚨')) {
                      return ListTile(
                        title: Text(
                          messageText,
                          style: const TextStyle(
                            color: Colors.red, // Define a cor vermelha para o alerta
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    } else {
                      return ListTile(
                        title: Text(messageText),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Escreva sua mensagem...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isAlertButtonEnabled ? _sendAlert : null,
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (_isAlertButtonEnabled) {
                    return Colors.red; // Cor do texto quando habilitado
                  }
                  return null; // Mantém o padrão quando desabilitado
                },
              ),
            ),
            child: const Text('Enviar Alerta de Emergência'),
          ),
        ],
      ),
    );
  }
}
