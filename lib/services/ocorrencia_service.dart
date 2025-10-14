import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:criar_telas/models/ocorrencia_model.dart';

class OcorrenciaService {
  final String baseUrl = 'http://localhost:8080/ocorrencia';

  /// Busca ocorrências pendentes
  Future<List<Ocorrencia>> getOcorrenciaPendentes() async {
    final response = await http.get(Uri.parse('$baseUrl/pendentes'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Ocorrencia.fromMap(e)).toList();
    } else {
      throw Exception('Erro ao carregar ocorrências pendentes');
    }
  }

  /// Busca ocorrências solucionadas
  Future<List<Ocorrencia>> getOcorrenciaSolucionadas() async {
    final response = await http.get(Uri.parse('$baseUrl/solucionadas'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Ocorrencia.fromMap(e)).toList();
    } else {
      throw Exception('Erro ao carregar ocorrências solucionadas');
    }
  }

  /// Busca uma ocorrência pelo ID
  Future<Ocorrencia> getOcorrenciaPorId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/findById/$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Ocorrencia.fromMap(data);
    } else if (response.statusCode == 404) {
      throw Exception('Ocorrência não encontrada');
    } else {
      throw Exception('Erro ao buscar ocorrência');
    }
  }

  /// Cria uma nova ocorrência via POST
  Future<Ocorrencia> criarOcorrencia(Ocorrencia ocorrencia) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ocorrencia.toMap()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Ocorrencia.fromMap(data);
    } else {
      throw Exception('Erro ao criar ocorrência');
    }
  }

  Future<Ocorrencia> update(int id, Ocorrencia ocorrencia) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ocorrencia.toMap()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Ocorrencia.fromMap(data);
      } else {
        throw Exception('Erro ao editar ocorrência: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao editar ocorrência: $e');
    }
  }

  /// Marca uma ocorrência como resolvida via PUT
  Future<void> marcarComoResolvida(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id/resolver'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao marcar ocorrência como resolvida: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao marcar como resolvida: $e');
    }
  }

  Future<void> inativar(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id/inativar'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao inativar ocorrência: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao inativar: $e');
    }
  }

  Future<void> deletar(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Erro ao deletar ocorrência: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao deletar: $e');
    }
  }

  /// Busca ocorrências de um usuário específico
  Future<List<Map<String, dynamic>>> getOcorrenciasDoUsuario(int userId) async {
    final response = await http.get(Uri.parse('http://localhost:8080/usuario/$userId/ocorrencias'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro ao carregar ocorrências do usuário');
    }
  }
}
