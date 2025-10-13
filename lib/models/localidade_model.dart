class Localidade {
  final int id;
  final String nome;

  Localidade({
    required this.id,
    required this.nome,
  });

  factory Localidade.fromMap(Map<String, dynamic> map) {
    return Localidade(
      id: map['id'],
      nome: map['nome'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
    };
  }
}
