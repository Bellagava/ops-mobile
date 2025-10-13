import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/auth_service.dart';

void main() => runApp(const OcorrenciaApp());

class OcorrenciaApp extends StatelessWidget {
  const OcorrenciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CriarOcorrenciaPage(),
    );
  }
}

class CriarOcorrenciaPage extends StatefulWidget {
  const CriarOcorrenciaPage({super.key});

  @override
  State<CriarOcorrenciaPage> createState() => _CriarOcorrenciaPageState();
}

class _CriarOcorrenciaPageState extends State<CriarOcorrenciaPage> {
  final TextEditingController problemaController = TextEditingController();
  List<dynamic> localidades = [];
  dynamic localidadeSelecionada;

  @override
  void initState() {
    super.initState();
    carregarLocalidades();
  }

  Future<void> carregarLocalidades() async {
    // Primeiro tenta carregar do servidor
    final url = Uri.parse('http://localhost:8080/localidade/findAll');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          localidades = jsonDecode(response.body);
        });
        return;
      }
    } catch (e) {
      // Se falhar, usa localidades estáticas
    }
  }

  Future<void> enviarOcorrencia() async {
    if (localidadeSelecionada == null ||
        problemaController.text.trim().isEmpty) {
      mostrarErro('Por favor, selecione uma localidade e descreva o problema.');
      return;
    }

    // Pega o RM do usuário logado
    String? userRm = await AuthService.getCurrentUserRm();
    if (userRm == null) {
      mostrarErro('Usuário não está logado');
      return;
    }

    int? userId = await AuthService.getCurrentUserId();
    if (userId == null) {
      mostrarErro('Usuário não está logado');
      return;
    }

    // Garante que o ID seja um número válido
    int localidadeId;
    try {
      localidadeId = int.parse(localidadeSelecionada['id'].toString());
    } catch (e) {
      mostrarErro('Erro: ID da localidade inválido');
      return;
    }

    final url = Uri.parse('http://localhost:8080/ocorrencia/save');
    final body = {
      'usuario_id': userId,
      'localidade_id': localidadeId,
      'descricao': problemaController.text.trim(),
      'statusOcorrencia': 'Pendente',
    };

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ocorrência criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        String errorMsg = 'Erro ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMsg = errorBody['message'] ?? errorMsg;
        } catch (_) {}
        mostrarErro('Erro ao criar ocorrência: $errorMsg');
      }
    } catch (e) {
      mostrarErro('Erro de conexão: $e');
    }
  }

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    problemaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1226),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset('assets/images/opsdeitado.png', height: 80),
              const SizedBox(height: 20),
              const Text(
                'CRIE A OCORRÊNCIA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECIONE A LOCALIDADE:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<dynamic>(
                      value: localidadeSelecionada,
                      items: localidades.map((local) {
                        return DropdownMenuItem(
                          value: local,
                          child: Text(local['nome']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          localidadeSelecionada = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'DESCREVA O PROBLEMA:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: problemaController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'escreva:',
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                'ENVIAR',
                onPressed: enviarOcorrencia,
                filled: true,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                'CANCELAR',
                onPressed: () => Navigator.pop(context),
                filled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label, {
    required VoidCallback onPressed,
    required bool filled,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? const Color(0xFF0C1226) : Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: filled ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
