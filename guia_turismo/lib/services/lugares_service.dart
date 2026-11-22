import 'dart:convert';

import 'package:guia_turismo/models/categoria_model.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:http/http.dart' as http;

class LugaresService {
  final String baseUrl = 'https://guiaturismo.onrender.com';
  String get url => '$baseUrl/lugares';
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

  // Envia um lugar autenticado e retorna a mensagem informada pela API.
  Future<String> cadastrarLugar(LugaresModel dados, String token) async {
    print('1. Entrou no cadastrarLugar | token vazio? ${token.isEmpty}');

    if (token.isEmpty) {
      return 'Token de autenticação não fornecido.';
    }

    try {
      final bodyJson = json.encode(dados.toJson());
      print('2. Enviando POST para $url');
      print('2.1. JSON enviado: $bodyJson');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: bodyJson,
      );

      print('3. STATUS POST /lugares: ${response.statusCode}');
      print('3.1. BODY POST /lugares: ${response.body}');

      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Resposta inválida do servidor.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          decoded['message']?.toString() ??
              'Falha ao cadastrar o lugar (${response.statusCode}).',
        );
      }
      return decoded['message']?.toString() ?? 'Lugar cadastrado com sucesso.';
    } catch (e) {
      print('4. ERRO NO CATCH cadastrarLugar: $e');
      throw Exception('Erro ao cadastrar o lugar: $e');
    }
  }
}