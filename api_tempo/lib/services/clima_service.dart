import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:api_tempo/models/clima_model.dart';

class ClimaService {
  // Atenção: idealmente a chave deve ser armazenada de forma segura (não em código fonte)
  final String _apiKey = 'fe71d2481a264a9fb0501731261308';

  Future<ClimaModel> buscarClima(String cidade) async {
    final uri = Uri.https('api.weatherapi.com', '/v1/current.json', {
      'key': _apiKey,
      'q': cidade,
      'aqi': 'no',
    });

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> dados = jsonDecode(response.body);
      return ClimaModel.fromJson(dados);
    } else {
      throw Exception('Falha ao buscar clima: ${response.statusCode}');
    }
  }
}
