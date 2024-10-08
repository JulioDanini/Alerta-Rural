import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_page.dart'; // Importe a página de chat
import 'package:cloud_firestore/cloud_firestore.dart'; // Para usar o Firestore

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _rememberMe = false; // Variável para controlar o estado de "Lembrar Senha"

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // Carrega as credenciais salvas ao iniciar
  }

  void _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        _rememberMe = true;
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
      });
    }
  }

  // Função para verificar se o usuário é master
  Future<bool> checkIfUserIsMaster(String userId) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;

        // Altera o campo para 'isMasterUser'
        return data?['isMasterUser'] ?? false;
      }
    } catch (e) {
      print('Erro ao verificar se o usuário é master: $e');
    }
    
    return false; // Retorna false se o documento não existir ou ocorrer um erro
  }

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_rememberMe) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        await prefs.setBool('rememberMe', true);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('email');
        await prefs.remove('password');
        await prefs.setBool('rememberMe', false);
      }

      bool isMaster = await checkIfUserIsMaster(userCredential.user!.uid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(isMasterUser: isMaster),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text('Usuário ou senha incorretos.'),
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

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Esqueci minha senha',
            style: TextStyle(color: Colors.green),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Digite o seu e-mail para redefinir sua senha.'),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String resetEmail = _emailController.text;
                if (resetEmail.isNotEmpty) {
                  try {
                    await _auth.sendPasswordResetEmail(email: resetEmail);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Nova senha enviada para $resetEmail.'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao enviar email de redefinição.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Enviar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Alerta Rural'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    const Text('Lembrar Senha'),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _forgotPassword,
              child: const Text('Esqueci minha senha'),
            ),
            const Spacer(), 
            const Text('Versão: 1.0.0'), 
            const SizedBox(height: 5),
            const Text('Desenvolvido por Julio Danini - Copyright'),
          ],
        ),
      ),
    );
  }
}
