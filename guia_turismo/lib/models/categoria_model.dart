class CategoriaModel {
  final int id;
  final String nome;

  const CategoriaModel({required this.id, required this.nome});

  // Converte a categoria recebida da API para o modelo usado no cadastro.
  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nome: json['nome']?.toString() ?? '',
    );
  }
}
