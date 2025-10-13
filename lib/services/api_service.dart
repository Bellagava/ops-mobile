import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api';
  
  static Future<bool> login(String rm, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rm': rm, 'senha': senha}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> register(String rm, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rm': rm, 'senha': senha}),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}