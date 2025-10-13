import 'package:criar_telas/services/auth_service.dart';
import 'package:criar_telas/services/ocorrencia_service.dart';
import 'package:flutter/material.dart';

class ListaOcorrenciasPage extends StatefulWidget {
  const ListaOcorrenciasPage({super.key});

  @override
  State<ListaOcorrenciasPage> createState() => _ListaOcorrenciasPageState();
}

class _ListaOcorrenciasPageState extends State<ListaOcorrenciasPage> {
  List<Map<String, dynamic>> ocorrencias = [];
  bool isLoading = true;
  final OcorrenciaService _ocorrenciaService = OcorrenciaService();

  @override
  void initState() {
    super.initState();
    carregarOcorrencias();
  }

  Future<void> carregarOcorrencias() async {
    try {
      int? userId = await AuthService.getCurrentUserId();
      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      final ocorrenciasUsuario = await _ocorrenciaService.getOcorrenciasDoUsuario(userId);
      setState(() {
        ocorrencias = ocorrenciasUsuario;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Ocorrências'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ocorrencias.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhuma ocorrência encontrada.',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: carregarOcorrencias,
                  child: ListView.builder(
                    itemCount: ocorrencias.length,
                    itemBuilder: (context, index) {
                      final ocorrencia = ocorrencias[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(ocorrencia['statusOcorrencia']),
                            child: Icon(
                              _getStatusIcon(ocorrencia['statusOcorrencia']),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            ocorrencia['descricao'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Local: ${ocorrencia['localidade_nome'] ?? 'N/A'}'),
                              Text('Status: ${ocorrencia['statusOcorrencia']}'),
                              Text('Data: ${_formatDate(ocorrencia['dataOcorrencia'])}'),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'resolvida':
      case 'solucionada':
        return Colors.green;
      case 'em andamento':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Icons.pending;
      case 'resolvida':
      case 'solucionada':
        return Icons.check_circle;
      case 'em andamento':
        return Icons.hourglass_empty;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
