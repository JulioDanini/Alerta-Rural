import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart'; // Importa o pacote de máscara

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
  final MaskedTextController _emergencyPhoneController = MaskedTextController(
      mask: '(00)00000-0000'); // Aplica a máscara de telefone
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Preencher os campos com valores de exemplo
    _idController.text = "123456";
    _propertyNameController.text = "Fazenda Esperança";
    _ruralCodeController.text = "RURAL-001";
    _emailController.text = "usuario@exemplo.com";
    _locationController.text = "X6C9+VW São Carlos, São Paulo";
    _nameController.text = "João Silva";
    _emergencyPhoneController.text =
        "(99)99999-9999"; // Preenche o telefone de emergência com a máscara
  }

  // Função de validação de número de telefone
  bool _validatePhoneNumber(String phone) {
    final RegExp phoneExp = RegExp(r'^\(\d{2}\)\d{4,5}-\d{4}$');
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
            // Nome (editável)
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),

            // Telefone de Emergência (com máscara)
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

            // E-mail (não editável)
            ListTile(
              title: const Text('E-mail'),
              subtitle: Text(_emailController.text),
            ),
            const SizedBox(height: 16),

            // ID (não editável)
            ListTile(
              title: const Text('ID do Usuário'),
              subtitle: Text(_idController.text),
            ),
            const SizedBox(height: 16),

            // Nome da Propriedade (não editável)
            ListTile(
              title: const Text('Nome da Propriedade'),
              subtitle: Text(_propertyNameController.text),
            ),
            const SizedBox(height: 16),

            // Código Rural (não editável)
            ListTile(
              title: const Text('Código Rural do Município'),
              subtitle: Text(_ruralCodeController.text),
            ),
            const SizedBox(height: 16),

            // Localização (não editável)
            ListTile(
              title: const Text('Geolocalização PLus Codes'),
              subtitle: Text(_locationController.text),
            ),
            const SizedBox(height: 16),

            // Botão para salvar as alterações
            ElevatedButton(
              onPressed: () {
                if (_validatePhoneNumber(_emergencyPhoneController.text)) {
                  widget.onLocationSaved(
                    _locationController.text,
                    _propertyNameController.text,
                    _ruralCodeController.text,
                    _emergencyPhoneController.text,
                    _nameController.text,
                    _idController.text,
                    _emailController.text,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Por favor, insira um número de telefone válido')),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
