import 'package:flutter/material.dart';
import 'occorrencia.dart';
import 'login.dart';
import 'services/ocorrencia_service.dart';
import 'services/auth_service.dart';
import 'models/ocorrencia_model.dart';
import 'vizualizar_ocorrencia.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final OcorrenciaService _ocorrenciaService = OcorrenciaService();
  String? userRm;
  int? userId;
  Future<List<Ocorrencia>>? _futureOcorrencias;

  @override
  void initState() {
    super.initState();
    _loadUserRm();
  }

  Future<void> _loadUserRm() async {
    final rm = await AuthService.getCurrentUserRm();
    final id = await AuthService.getCurrentUserId();
    setState(() {
      userRm = rm;
      userId = id;
      if (id != null) {
        _loadOcorrencias();
      }
    });
  }

  void _loadOcorrencias() {
<<<<<<< HEAD
    setState(() {
      final isPending = selectedIndex == 0;
      _futureOcorrencias = isPending
          ? _ocorrenciaService.getOcorrenciaPendentes()
          : _ocorrenciaService.getOcorrenciaSolucionadas();
    });
=======
    if (userId == null) return;
    
    final isPending = selectedIndex == 0;
    _futureOcorrencias = isPending
        ? _ocorrenciaService.getOcorrenciaPendentesPorUsuario(userId!)
        : _ocorrenciaService.getOcorrenciasSolucionadasPorUsuario(userId!);
>>>>>>> 4d926ba (ultima atualização do front)
  }

  @override
  Widget build(BuildContext context) {
    final isPending = selectedIndex == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Image.asset(
                'assets/images/opsdeitado.png',
                height: 80,
              ),
              const SizedBox(height: 24),
              _buildTitleBox('OCORRÊNCIAS'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      selectedIndex = 0;
                      _loadOcorrencias();
                    }),
                    child: _buildButton('PENDENTES', ativo: isPending),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      selectedIndex = 1;
                      _loadOcorrencias();
                    }),
                    child: _buildButton('SOLUCIONADAS', ativo: !isPending),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isPending
                      ? 'HISTÓRICO DE PENDENTES:'
                      : 'HISTÓRICO DE SOLUCIONADAS:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _futureOcorrencias == null
                    ? const Center(child: CircularProgressIndicator())
                    : FutureBuilder<List<Ocorrencia>>(
                  future: _futureOcorrencias!,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro ao carregar ocorrências',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      );
                    }
                    final ocorrencias = snapshot.data ?? [];
                    if (ocorrencias.isEmpty) {
                      return Center(
                        child: Text(
                          isPending
                              ? 'Não há ocorrências pendentes'
                              : 'Não há ocorrências solucionadas',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: ocorrencias.length,
                      itemBuilder: (context, index) {
                        final ocorrencia = ocorrencias[index];
                        return GestureDetector(
                          onTap: () async {
                            final resultado = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VisualizarOcorrenciaPage(
                                  ocorrenciaId: ocorrencia.id,
                                ),
                              ),
                            );
                            if (resultado == 'deleted' || resultado == 'inativada') {
                              setState(() {
                                _loadOcorrencias();
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: _buildCard(
                              ocorrencia: ocorrencia,
                              isPending: isPending,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildCriarOcorrenciaButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildButton(String text, {required bool ativo}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1226),
        borderRadius: BorderRadius.circular(12),
        boxShadow: ativo
            ? [
                const BoxShadow(
                    color: Colors.black38, blurRadius: 4, offset: Offset(2, 2))
              ]
            : [],
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTitleBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.grey[300],
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildCard({required Ocorrencia ocorrencia, required bool isPending}) {
    final status = isPending ? 'PENDENTE' : 'SOLUCIONADA';
    final color = isPending ? const Color(0xFFD32F2F) : Colors.green;
    final bgColor = isPending ? const Color(0xFFFFE5E5) : Colors.green[100]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Data De Envio: ${ocorrencia.dataOcorrencia.day}/${ocorrencia.dataOcorrencia.month}/${ocorrencia.dataOcorrencia.year}'),
          Text('Nº Da Ocorrência: ${ocorrencia.id}'),
          Text('Lab: ${ocorrencia.localidade.nome}'),
          const SizedBox(height: 8),
          Text('Status: $status',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCriarOcorrenciaButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () async {
        final resultado = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CriarOcorrenciaPage()),
        );

        // Se uma nova ocorrência foi criada, atualizar a tela
        if (resultado != null) {
          setState(() {
            _loadOcorrencias();
          });
        }
      },
      icon: const Icon(Icons.add, color: Colors.black),
      label:
          const Text('CRIAR OCORRÊNCIA', style: TextStyle(color: Colors.black)),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: const Color(0xFF0C1226),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.account_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(userRm != null ? 'RM: $userRm' : 'Carregando...',
                style: const TextStyle(color: Colors.white)),
          ),
          GestureDetector(
            onTap: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Sair da Conta',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                )),
          ),
        ],
      ),
    );
  }
}
