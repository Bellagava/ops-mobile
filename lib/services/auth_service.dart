import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import 'api_service.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userRmKey = 'userRm';

  
  static Future<String> register(String rm, String senha) async {
    // Valida formato do RM
    if (!_isValidRM(rm)) {
      return 'invalid_rm';
    }
    
    // Verifica se usuário já existe localmente
    if (await DatabaseService.userExists(rm)) {
      return 'rm_exists';
    }
    
    // Tenta primeiro com a API
    bool apiSuccess = await ApiService.register(rm, senha);
    if (apiSuccess) {
      // Se sucesso na API, salva também localmente
      await DatabaseService.registerUser(rm, senha);
      return 'success';
    }
    
    // Se falhar na API, tenta apenas local
    bool localSuccess = await DatabaseService.registerUser(rm, senha);
    return localSuccess ? 'success' : 'error';
  }

  static bool _isValidRM(String rm) {
    if (rm.isEmpty) return false;
    if (rm.length < 4 || rm.length > 10) return false;
    return RegExp(r'^[0-9]+$').hasMatch(rm);
  }

  static Future<void> _saveSession(String rm) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userRmKey, rm);
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<String?> getCurrentUserRm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRmKey);
  }

  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userRmKey);
  }
}