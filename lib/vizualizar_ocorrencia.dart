import 'package:flutter/material.dart';
import 'models/ocorrencia_model.dart';
import 'services/ocorrencia_service.dart';
import 'editar_ocorrencia_page.dart';

class VisualizarOcorrenciaPage extends StatefulWidget {
  final int ocorrenciaId;

  const VisualizarOcorrenciaPage({super.key, required this.ocorrenciaId});

  @override
  State<VisualizarOcorrenciaPage> createState() => _VisualizarOcorrenciaPageState();
}

class _VisualizarOcorrenciaPageState extends State<VisualizarOcorrenciaPage> {
  final OcorrenciaService ocorrenciaService = OcorrenciaService();
  late Future<Ocorrencia> _ocorrenciaFuture;

  @override
  void initState() {
    super.initState();
    _ocorrenciaFuture = ocorrenciaService.getOcorrenciaPorId(widget.ocorrenciaId);
  }

  Future<void> _recarregarOcorrencia() async {
    setState(() {
      _ocorrenciaFuture = ocorrenciaService.getOcorrenciaPorId(widget.ocorrenciaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1226),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1226),
        title: const Text('Detalhes da Ocorrência', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Ocorrencia>(
        future: _ocorrenciaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Ocorrência não encontrada'));
          }

          final ocorrencia = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/opsdeitado.png', height: 80),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ocorrência #${ocorrencia.id}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildInfoRow('Data de Envio:',
                          '${ocorrencia.dataOcorrencia.day}/${ocorrencia.dataOcorrencia.month}/${ocorrencia.dataOcorrencia.year}'),
                      _buildInfoRow('Status:',
                          ocorrencia.statusOcorrencia,
                          valueColor: ocorrencia.statusOcorrencia == 'SOLUCIONADA' ? Colors.green : Colors.red),
                      _buildInfoRow('Localidade:', ocorrencia.localidade.nome),
                      const SizedBox(height: 10),
                      const Text('Descrição do Problema:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(ocorrencia.descricao),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    _buildButton('VOLTAR', const Color(0xFF0C1226), () {
                      Navigator.pop(context);
                    }),
                    const SizedBox(height: 10),
                    _buildButton('EDITAR', Colors.blue, () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditarOcorrenciaPage(ocorrencia: ocorrencia),
                        ),
                      );
                      if (resultado == true) await _recarregarOcorrencia();
                    }),
                    const SizedBox(height: 10),
                    _buildButton('INATIVAR', Colors.orange, () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Inativar Ocorrência'),
                          content: const Text('Tem certeza que deseja inativar esta ocorrência?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  Navigator.pop(context); // Fecha o dialog primeiro
                                  
                                  // Mostra loading
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                  
                                  await ocorrenciaService.inativar(ocorrencia.id);
                                  
                                  Navigator.pop(context); // Fecha o loading
                                  Navigator.pop(context, 'inativada'); // Volta para lista
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Ocorrência inativada com sucesso')),
                                  );
                                } catch (e) {
                                  Navigator.pop(context); // Fecha o loading se houver erro
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro ao inativar: $e'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Inativar', style: TextStyle(color: Colors.orange)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          Expanded(child: Text(value, style: TextStyle(color: valueColor))),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
