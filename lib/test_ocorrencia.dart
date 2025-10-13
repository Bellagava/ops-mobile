import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const TestOcorrenciaApp());

class TestOcorrenciaApp extends StatelessWidget {
  const TestOcorrenciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TestOcorrenciaPage(),
    );
  }
}

class TestOcorrenciaPage extends StatefulWidget {
  const TestOcorrenciaPage({super.key});

  @override
  State<TestOcorrenciaPage> createState() => _TestOcorrenciaPageState();
}

class _TestOcorrenciaPageState extends State<TestOcorrenciaPage> {
  final TextEditingController problemaController = TextEditingController();
  bool isLoading = false;
  String resultado = '';

  Future<void> testarConexao() async {
    setState(() {
      isLoading = true;
      resultado = 'Testando conexão...';
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/localidade/findAll'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          resultado = '✅ Servidor funcionando! Localidades: ${data.length}';
        });
      } else {
        setState(() {
          resultado = '❌ Erro: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        resultado = '❌ Erro de conexão: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> testarOcorrencia() async {
    if (problemaController.text.trim().isEmpty) {
      setState(() {
        resultado = '❌ Digite uma descrição do problema';
      });
      return;
    }

    setState(() {
      isLoading = true;
      resultado = 'Enviando ocorrência...';
    });

    try {
      final body = {
        'localidade_id': 1,
        'descricao': problemaController.text.trim(),
        'statusOcorrencia': 'ABERTA',
        'usuario_id': 1,
      };

      print('Enviando dados: $body');

      final response = await http.post(
        Uri.parse('http://localhost:3000/ocorrencia/save'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      print('Status da resposta: ${response.statusCode}');
      print('Corpo da resposta: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          resultado = '✅ Ocorrência criada com sucesso! ID: ${data['id']}';
        });
        problemaController.clear();
      } else {
        setState(() {
          resultado = '❌ Erro ${response.statusCode}: ${response.body}';
        });
      }
    } catch (e) {
      print('Erro ao enviar ocorrência: $e');
      setState(() {
        resultado = '❌ Erro de conexão: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1226),
      appBar: AppBar(
        title: const Text('Teste de Ocorrência'),
        backgroundColor: const Color(0xFF0C1226),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TESTE DE CONEXÃO:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : testarConexao,
                      child: const Text('Testar Servidor'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'DESCRIÇÃO DO PROBLEMA:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: problemaController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Digite o problema...',
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : testarOcorrencia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C1226),
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('ENVIAR OCORRÊNCIA'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESULTADO:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    resultado.isEmpty ? 'Nenhum teste executado ainda' : resultado,
                    style: TextStyle(
                      color: resultado.startsWith('✅') ? Colors.green : 
                             resultado.startsWith('❌') ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}