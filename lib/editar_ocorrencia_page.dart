import 'package:criar_telas/vizualizar_ocorrencia.dart';
import 'package:flutter/material.dart';
import 'models/ocorrencia_model.dart';
import 'models/localidade_model.dart';
import 'services/ocorrencia_service.dart';

class EditarOcorrenciaPage extends StatefulWidget {
  final Ocorrencia ocorrencia;

  const EditarOcorrenciaPage({super.key, required this.ocorrencia});

  @override
  State<EditarOcorrenciaPage> createState() => _EditarOcorrenciaPageState();
}

class _EditarOcorrenciaPageState extends State<EditarOcorrenciaPage> {
  final _formKey = GlobalKey<FormState>();
  final OcorrenciaService _service = OcorrenciaService();

  late TextEditingController _descricaoController;
  late TextEditingController _statusController;
  late TextEditingController _localidadeController;

  @override
  void initState() {
    super.initState();
    _descricaoController =
        TextEditingController(text: widget.ocorrencia.descricao);
    _statusController =
        TextEditingController(text: widget.ocorrencia.statusOcorrencia);
    _localidadeController =
        TextEditingController(text: widget.ocorrencia.localidade.nome);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _statusController.dispose();
    _localidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      final ocorrenciaAtualizada = Ocorrencia(
        id: widget.ocorrencia.id,
        usuario: widget.ocorrencia.usuario,
        localidade: Localidade(
          id: widget.ocorrencia.localidade.id,
          nome: _localidadeController.text,
        ),
        dataOcorrencia: widget.ocorrencia.dataOcorrencia,
        descricao: _descricaoController.text,
        statusOcorrencia: _statusController.text,
      );

      try {
        await _service.update(widget.ocorrencia.id, ocorrenciaAtualizada);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocorrência atualizada com sucesso')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VisualizarOcorrenciaPage(ocorrenciaId: widget.ocorrencia.id),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1226),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1226),
        title: const Text('Editar Ocorrência',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Localidade:',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _localidadeController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Ex: Laboratório 1, Sala 201...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Localidade obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Descrição do Problema:',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Digite a descrição...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Descrição obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _salvarAlteracoes,
                    child: const Text('SALVAR ALTERAÇÕES'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
