class ClimaModel {
  final String cidade;
  final double temperatura;
  final String descricao;
  final int umidade;
  final double vento;
  final String icone;

  ClimaModel({
    required this.cidade,
    required this.temperatura,
    required this.descricao,
    required this.umidade,
    required this.vento,
    required this.icone,
  });

  factory ClimaModel.fromJson(Map<String, dynamic> json) {
    return ClimaModel(
      cidade: json['location']?['name'] ?? '',
      temperatura: (json['current']?['temp_c'] is num)
          ? (json['current']!['temp_c'] as num).toDouble()
          : double.tryParse(json['current']?['temp_c']?.toString() ?? '') ?? 0.0,
      descricao: json['current']?['condition']?['text'] ?? '',
      umidade: (json['current']?['humidity'] is int)
          ? json['current']!['humidity'] as int
          : int.tryParse(json['current']?['humidity']?.toString() ?? '') ?? 0,
      vento: (json['current']?['wind_kph'] is num)
          ? (json['current']!['wind_kph'] as num).toDouble()
          : double.tryParse(json['current']?['wind_kph']?.toString() ?? '') ?? 0.0,
      icone: json['current']?['condition']?['icon'] ?? '',
    );
  }
}
