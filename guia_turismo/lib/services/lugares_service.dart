import 'dart:convert';

import 'package:guia_turismo/models/categoria_model.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:http/http.dart' as http;

class LugaresService {
  final String baseUrl = 'https://guiaturismo.onrender.com';
  // Monta o endereço usado nas consultas de lugares.
  String get url => '$baseUrl/lugares';
  // Valores usados na paginação da busca.
  int pagina = 1;
  int limite = 1000;

  // Busca as categorias válidas para relacionar o novo lugar à API.
  Future<List<CategoriaModel>> buscarCategorias() async {
    final response = await http.get(Uri.parse('$baseUrl/categorias'));
    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao carregar as categorias (${response.statusCode}).',
      );
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
      throw const FormatException('Resposta de categorias inválida.');
    }

    return (decoded['data'] as List).map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Uma categoria recebida é inválida.');
      }
      return CategoriaModel.fromJson(item);
    }).toList();
  }

  // Carrega a página atual de lugares e converte a resposta para os modelos.
  Future<List<LugaresModel>> buscarLugares() async {
    try {
      final response = await http.get(
        Uri.parse('$url?pagina=$pagina&limite=$limite'),
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Falha ao carregar os lugares (${response.statusCode}).',
        );
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Resposta inválida do servidor.');
      }
      final data = decoded['data'];
      if (data is! List) {
        throw const FormatException('Lista de lugares ausente na resposta.');
      }

      return data.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException(
            'Um item da lista de lugares é inválido.',
          );
        }
        return LugaresModel.fromJson(item);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar os lugares: $e');
    }
  }
}
