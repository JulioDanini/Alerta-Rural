import 'package:flutter/material.dart';
import 'login_page.dart'; // Importando a página de login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alerta Rural',
      theme: ThemeData(
        primarySwatch: Colors.green, // Define o tema principal
        scaffoldBackgroundColor: Colors.white, // Define o fundo brancogit
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
            backgroundColor: Colors.green, // Define a cor do texto do TextButton
            foregroundColor: Colors.white, // Cor do texto do botão
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
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green), // Cor da borda
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green), // Cor da borda quando habilitado
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green.shade700), // Cor da borda quando em foco
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red), // Cor da borda quando há erro
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700), // Cor da borda quando em foco e erro
          ),
          labelStyle: TextStyle(color: Colors.green), // Cor do texto do rótulo
          hintStyle: TextStyle(color: Colors.green.shade300), // Cor do texto de dica
        ),
      ),
      home: const LoginPage(), // Define a tela inicial como LoginPage
    );
  }
}
