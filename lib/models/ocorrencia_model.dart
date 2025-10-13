import 'package:criar_telas/models/localidade_model.dart';
import 'package:criar_telas/models/usuario_model.dart';

class Ocorrencia {
  final int id;
  final Usuario usuario;
  final Localidade localidade;
  final DateTime dataOcorrencia;
  final String descricao;
  final String statusOcorrencia;

  Ocorrencia({
    required this.id,
    required this.usuario,
    required this.localidade,
    required this.dataOcorrencia,
    required this.descricao,
    required this.statusOcorrencia,
  });

  factory Ocorrencia.fromMap(Map<String, dynamic> map) {
    return Ocorrencia(
      id: map['id'],
      usuario: Usuario.fromMap(map['usuario']),
      localidade: Localidade.fromMap(map['localidade']),
      dataOcorrencia: DateTime.parse(map['dataOcorrencia']),
      descricao: map['descricao'],
      statusOcorrencia: map['statusOcorrencia'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario': usuario.toMap(),
      'localidade': localidade.toMap(),
      'dataOcorrencia': dataOcorrencia.toIso8601String(),
      'descricao': descricao,
      'statusOcorrencia': statusOcorrencia,
    };
  }
}
