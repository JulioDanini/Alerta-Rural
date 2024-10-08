import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart'; // Importando a página de login
import 'firebase_options.dart'; // Importa as opções geradas

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
        primarySwatch: Colors.green, // Define o tema principal
        scaffoldBackgroundColor: Colors.white, // Define o fundo branco
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green, // Cor da AppBar
          titleTextStyle: TextStyle(
            color: Colors.white, // Cor do texto do título
            fontSize: 20, // Tamanho da fonte (opcional)
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Cor do botão para verde
            foregroundColor: Colors.white, // Cor do texto do botão
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green, // Define a cor do texto do TextButton
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey; // Cor do botão quando desativado
              }
              return Colors.green; // Cor do botão do Switch
            },
          ),
          trackColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey.shade300; // Cor da trilha quando desativado
              }
              return Colors.green.shade300; // Cor da trilha do Switch
            },
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green), // Cor da borda
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green), // Cor da borda quando habilitado
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green.shade700), // Cor da borda quando em foco
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red), // Cor da borda quando há erro
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700), // Cor da borda quando em foco e erro
          ),
          labelStyle: const TextStyle(color: Colors.green), // Cor do texto do rótulo
          hintStyle: TextStyle(color: Colors.green.shade300), // Cor do texto de dica
        ),
      ),
      home: const LoginPage(), // Define a tela inicial como LoginPage
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
