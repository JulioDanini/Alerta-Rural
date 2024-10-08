import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instância do FirebaseAuth

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verifica se o usuário é master ou comum (pode ser baseado em roles, aqui simplificado)
      bool isMaster = email == 'admin@admin.com'; // Exemplo simplificado

      // Navegar para a página correta com base no tipo de usuário
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(isMasterUser: isMaster), // Passando se o usuário é master
        ),
      );
    } catch (e) {
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
              onPressed: () async {
                String resetEmail = _resetEmailController.text;
                if (resetEmail.isNotEmpty) {
                  try {
                    await _auth.sendPasswordResetEmail(email: resetEmail);
                    // Fechar o diálogo após enviar
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Nova senha enviada para $resetEmail.'),
                      ),
                    );
                  } catch (e) {
                    // Exibir erro se o email não for encontrado
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
