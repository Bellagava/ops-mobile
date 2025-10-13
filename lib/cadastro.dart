import 'package:flutter/material.dart';
import 'login.dart';
import 'cadastro_controller.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> with SingleTickerProviderStateMixin {
  final _nomeController = TextEditingController();
  final _rmController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    bool isAluno = _tabController.index == 0;
    
    if (_nomeController.text.isEmpty || _senhaController.text.isEmpty) {
      _showMessage('Preencha nome e senha');
      return;
    }
    
    if (isAluno && _rmController.text.isEmpty) {
      _showMessage('Preencha o RM');
      return;
    }
    
    if (!isAluno && _emailController.text.isEmpty) {
      _showMessage('Preencha o email');
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await CadastroController.cadastrar(
      _nomeController.text,
      isAluno ? _rmController.text : '',
      isAluno ? '' : _emailController.text,
      _senhaController.text,
    );
    
    setState(() => _isLoading = false);
    
    if (result['success']) {
      _showMessage(result['message']);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      _showMessage(result['message']);
    }


  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060C2C), // Fundo azul escuro
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Image.asset(
                'assets/images/imagem.png',
                height: 400,
              ),
              const SizedBox(height: 40),
              // Container branco com bordas arredondadas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CADASTRO',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B0F2F),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      labelColor: Color(0xFF0B0F2F),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Color(0xFF0B0F2F),
                      tabs: const [
                        Tab(text: 'ALUNO'),
                        Tab(text: 'PROFESSOR'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'NOME',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        hintText: 'Seu nome completo',
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 80,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Aba Aluno
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'RM',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextField(
                                controller: _rmController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Seu RM',
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ],
                          ),
                          // Aba Professor
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EMAIL',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Seu email',
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SENHA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _senhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Sua senha',
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                        ),
                        onPressed: _isLoading ? null : _cadastrar,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'CADASTRAR',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Já tem Cadastro? Faça Login',
                          style: TextStyle(
                            color: Color(0xFF0B0F2F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
