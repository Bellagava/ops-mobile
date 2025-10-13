import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CadastroController {
  static const String baseUrl = 'http://localhost:8080';

  static Future<Map<String, dynamic>> cadastrar(
    String nome,
    String rm,
    String email,
    String senha,
  ) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        String nivelAcesso = rm.trim().isEmpty ? 'PROFESSOR' : 'ALUNO';
        final client = http.Client();
        final response = await client
            .post(
              Uri.parse('$baseUrl/usuario/save'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'nome': nome,
                'rm': rm,
                'email': email,
                'senha': senha,
                'nivelAcesso': nivelAcesso,
                'dataCadastro': DateTime.now().toIso8601String(),
                'statusUsuario': 'ATIVO',
              }),
            )
            .timeout(const Duration(seconds: 10));

        client.close();

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {'success': true, 'message': 'Cadastro realizado com sucesso'};
        } else {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Erro no cadastro',
          };
        }
      } on SocketException {
        if (attempt == 2) {
          return {'success': false, 'message': 'Servidor indisponível'};
        }
        await Future.delayed(Duration(seconds: attempt + 1));
      } on HttpException {
        if (attempt == 2) {
          return {'success': false, 'message': 'Erro de conexão HTTP'};
        }
        await Future.delayed(Duration(seconds: attempt + 1));
      } catch (e) {
        if (attempt == 2) {
          return {'success': false, 'message': 'Erro de conexão'};
        }
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }
    return {'success': false, 'message': 'Falha na conexão'};
  }
}
