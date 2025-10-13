import 'package:flutter/material.dart';
import 'cadastro.dart';
import 'login.dart';
 
class PrincipalScreen extends StatelessWidget {
  const PrincipalScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060C2C), // Fundo azul escuro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone com engrenagem e ferramentas
            Image.asset(
              'assets/images/imagem.png',
               height: 400,
            ),
            const SizedBox(height: 40),
           
            const SizedBox(height: 40),
 
            // Container branco com opções
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'COMO GOSTARIA\nDE ACESSAR?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF060C2C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'SOU ALUNO',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'SOU PROFESSOR',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CadastroScreen()),
                      );
                    },
                    child: const Text(
                      'Não tem cadastro? Clique aqui',
                      style: TextStyle(
                        color: Color(0xFF060C2C),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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
 
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
 
  const CustomButton({super.key, required this.text, required this.onPressed});
 
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Botão ocupa toda a largura possível do container
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF060C2C),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.black45,
        ),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
