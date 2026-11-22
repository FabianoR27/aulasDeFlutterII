import 'package:guia_turismo/models/lugares_model.dart';
import 'package:http/http.dart' as http;

class OsmService {
  static const String _baseUrl = 'https://api.openstreetmap.org/api/0.6';

  Future<String> cadastrarLugar(LugaresModel lugar, String token) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'text/xml',
      'User-Agent': 'Rota Ciano/1.0',
    };
    final changesetResponse = await http.put(
      Uri.parse('$_baseUrl/changeset/create'),
      headers: headers,
      body: _xmlChangeset,
    );
    _validarResposta(changesetResponse, 'abrir o changeset');

    final changesetId = int.tryParse(changesetResponse.body.trim());
    if (changesetId == null) {
      throw const FormatException(
        'O OpenStreetMap retornou um changeset inválido.',
      );
    }

    try {
      final nodeResponse = await http.put(
        Uri.parse('$_baseUrl/node/create'),
        headers: headers,
        body: _xmlLugar(lugar, changesetId),
      );
      _validarResposta(nodeResponse, 'cadastrar o local');

      final nodeId = nodeResponse.body.trim();
      if (nodeId.isEmpty) {
        throw const FormatException(
          'O OpenStreetMap não retornou o ID do local.',
        );
      }

      return nodeId;
    } finally {
      final closeResponse = await http.put(
        Uri.parse('$_baseUrl/changeset/$changesetId/close'),
        headers: headers,
      );
      _validarResposta(closeResponse, 'fechar o changeset');
    }
  }

  String get _xmlChangeset =>
      '<osm><changeset>'
      '<tag k="created_by" v="Rota Ciano/1.0"/>'
      '<tag k="comment" v="Cadastro de local pelo Rota Ciano"/>'
      '</changeset></osm>';

  String _xmlLugar(LugaresModel lugar, int changesetId) {
    final tags = <String, String>{
      'name': lugar.nome,
      if (lugar.descricao.isNotEmpty) 'description': lugar.descricao,
    };

    switch (lugar.categoria?.toLowerCase()) {
      case 'praias':
        tags['natural'] = 'beach';
      case 'gastronomia':
        tags['amenity'] = 'restaurant';
      case 'ilhas':
        tags['place'] = 'island';
      default:
        tags['tourism'] = 'attraction';
    }

    final tagsXml = tags.entries
        .map(
          (tag) =>
              '<tag k="${_escaparXml(tag.key)}" v="${_escaparXml(tag.value)}"/>',
        )
        .join();

    return '<osm><node changeset="$changesetId" '
        'lat="${lugar.latitude}" lon="${lugar.longitude}">$tagsXml</node></osm>';
  }

  String _escaparXml(String valor) {
    return valor
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  void _validarResposta(http.Response response, String operacao) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detalhe = response.body.trim();
      throw Exception(
        'Falha ao $operacao no OpenStreetMap (${response.statusCode})'
        '${detalhe.isEmpty ? '.' : ': $detalhe'}',
      );
    }
  }
}
