import 'package:flutter/material.dart';
import 'chat_page.dart'; // Importe a página de chat

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController(); // Controlador para o email de resetar senha

  // Lista de usuários - você pode substituir isso por uma lógica de autenticação real
  final List<User> users = [
    User(name: 'admin', email: 'admin@admin.com', password: '123', isMaster: true), // Usuário master
    User(name: 'user', email: 'user@user.com', password: '123', isMaster: false), // Usuário comum
  ];

  void _login() {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Autenticação básica
    User? loggedInUser = users.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => User(name: '', email: '', password: '', isMaster: false),
    );

    if (loggedInUser.name.isNotEmpty) {
      // Navegar para a página correta com base no tipo de usuário
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(isMasterUser: loggedInUser.isMaster), // Passando se o usuário é master
        ),
      );
    } else {
      // Exibe mensagem de erro se o login falhar
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

  // Função para exibir caixa de diálogo "Esqueci minha senha"
  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
      return AlertDialog(
        title: const Text(
          'Esqueci minha senha',
          style: TextStyle(color: Colors.green), // Definindo a cor do texto do título
        ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Digite o seu e-mail para redefinir sua senha.'),
              TextField(
                controller: _resetEmailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Aqui você pode adicionar a lógica para enviar o email de redefinição
                String resetEmail = _resetEmailController.text;
                if (resetEmail.isNotEmpty) {
                  // Fechar o diálogo após enviar
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nova senha enviada para $resetEmail.'),
                    ),
                  );
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
            // Adiciona uma imagem acima dos campos
            Image.asset(
              'assets/logo.png', // Certifique-se de que o arquivo está no diretório assets
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
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _forgotPassword, // Chama a função de "Esqueci minha senha"
              child: const Text('Esqueci minha senha'),
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  final String name;
  final String email;
  final String password; // Adicione a propriedade de senha
  final bool isMaster;

  User({required this.name, required this.email, required this.password, required this.isMaster});
}
