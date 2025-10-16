import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/localidade_model.dart';

class LocalidadeService {
  final String baseUrl = 'http://localhost:8080/localidade';

  Future<List<Localidade>> getLocalidades() async {
    final response = await http.get(Uri.parse('$baseUrl/findAll'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Localidade.fromMap(e)).toList();
    } else {
      throw Exception('Erro ao carregar localidades');
    }
  }
}