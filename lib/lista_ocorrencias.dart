import 'package:criar_telas/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListaOcorrenciasPage extends StatefulWidget {
  const ListaOcorrenciasPage({super.key});

  @override
  State<ListaOcorrenciasPage> createState() => _ListaOcorrenciasPageState();
}

class _ListaOcorrenciasPageState extends State<ListaOcorrenciasPage> {
  List<dynamic> ocorrencias = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarOcorrencias();
  }

  Future<void> carregarOcorrencias() async {
    int? userId = await AuthService.getCurrentUserId();
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse('http://localhost:8080/usuario/$userId/ocorrencias');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          ocorrencias = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Ocorrências')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ocorrencias.isEmpty
              ? const Center(child: Text('Nenhuma ocorrência encontrada.'))
              : ListView.builder(
                  itemCount: ocorrencias.length,
                  itemBuilder: (context, index) {
                    final ocorrencia = ocorrencias[index];
                    return ListTile(
                      title: Text(ocorrencia['descricao']),
                      subtitle:
                          Text('Status: ${ocorrencia['statusOcorrencia']}'),
                      trailing: Text(ocorrencia['dataOcorrencia'] ?? ''),
                    );
                  },
                ),
    );
  }
}
