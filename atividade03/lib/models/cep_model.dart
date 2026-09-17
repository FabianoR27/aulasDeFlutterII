class CepModel {
  final String logradouro;
  final String localidade;
  final String uf;

  CepModel({
    required this.logradouro,
    required this.localidade,
    required this.uf,
  });

  factory CepModel.fromJson(Map<String, dynamic> json) {
    return CepModel(
      logradouro: json['logradouro'] ?? '',
      localidade: json['localidade'] ?? '',
      uf: json['uf'] ?? '',
    );
  }
}