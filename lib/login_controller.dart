import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  static const String baseUrl = 'http://localhost:8080';

  static Future<Map<String, dynamic>> login(
      String identifier, String senha, bool isAluno) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/usuario/login'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(isAluno
                  ? {'rm': identifier, 'senha': senha}
                  : {'email': identifier, 'senha': senha}),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Salvar dados do usuário na SharedPreferences
          await _saveUserData(data, isAluno);

          return {'success': true, 'data': data};
        } else {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Erro no login'
          };
        }
      } catch (e) {
        if (attempt == 2)
          return {'success': false, 'message': 'Erro de conexão'};
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }
    return {'success': false, 'message': 'Falha na conexão'};
  }

  static Future<void> _saveUserData(
      Map<String, dynamic> data, bool isAluno) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', data['id']);
    await prefs.setString('userRm', data['rm'] ?? '');
    await prefs.setString('userEmail', data['email'] ?? '');
    await prefs.setString('userSenha', data['senha'] ?? '');
    await prefs.setBool('isAluno', isAluno);
    await prefs.setBool('isLoggedIn', true);
  }

  static Future<void> _saveUserSession(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRm', identifier);
    await prefs.setBool('isLoggedIn', true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userRm');
    await prefs.remove('isLoggedIn');
  }
}
