// a classe contato
class ContatoModel {
  int? id;
  final String? nome;
  final String? telefone;
  final String? email;

  // construtor
  ContatoModel({
    required this.nome,
    required this.telefone,
    required this.email,
    this.id,
  });

  factory ContatoModel.fromJson(Map json) {
    return ContatoModel(
      id: json['id'],
      nome: json['nome'],
      telefone: json['telefone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'email': email,
    };
  }
}