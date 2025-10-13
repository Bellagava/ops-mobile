class User {
  final int? id;
  final String rm;
  final String senha;

  User({
    this.id,
    required this.rm,
    required this.senha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rm': rm,
      'senha': senha,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      rm: map['rm'],
      senha: map['senha'],
    );
  }
}