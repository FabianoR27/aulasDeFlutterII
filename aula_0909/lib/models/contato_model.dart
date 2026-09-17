class ContatoModel {
  int? id;
  final String nome;
  final String email;
  final String telefone;
  
  ContatoModel({
    required this.nome,
    required this.email,
    required this.telefone,
    this.id
  });

  factory ContatoModel.fromJson(Map json) {
    return ContatoModel(
      id: json['id'],
      nome: json['nome'], 
      email: json['email'], 
      telefone: json['telefone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nome": nome,
      "email": email,
      "telefone": telefone
    };
  }
}