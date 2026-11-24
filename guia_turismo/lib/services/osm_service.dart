import 'package:flutter/foundation.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/services/osm_config.dart';
import 'package:http/http.dart' as http;

class OsmUnauthorizedException implements Exception {
  const OsmUnauthorizedException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class OsmService {
  static const String _baseUrl = OsmConfig.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 20);

  // Abre um changeset, cria o ponto e fecha o changeset no final.
  Future<String> cadastrarLugar(LugaresModel lugar, String token) async {
    // Cabeçalhos usados em todas as chamadas feitas ao OpenStreetMap.
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'text/xml',
      'User-Agent': 'Rota do Fabiano/1.0',
    };
    final changesetResponse = await http
        .put(
          Uri.parse('$_baseUrl/changeset/create'),
          headers: headers,
          body: _xmlChangeset,
        )
        .timeout(_timeout);
    _validarResposta(changesetResponse, 'abrir o changeset');

    final changesetId = int.tryParse(changesetResponse.body.trim());
    if (changesetId == null) {
      throw const FormatException(
        'O OpenStreetMap retornou um changeset inválido.',
      );
    }

    try {
      final nodeResponse = await http
          .put(
            Uri.parse('$_baseUrl/node/create'),
            headers: headers,
            body: montarXmlLugar(lugar, changesetId),
          )
          .timeout(_timeout);
      _validarResposta(nodeResponse, 'cadastrar o local');

      final nodeId = nodeResponse.body.trim();
      if (nodeId.isEmpty) {
        throw const FormatException(
          'O OpenStreetMap não retornou o ID do local.',
        );
      }

      return nodeId;
    } finally {
      // Nunca lança exceção no finally para não mascarar erros de node/create
      // nem descartar um ponto que já foi criado com sucesso.
      try {
        final closeResponse = await http
            .put(
              Uri.parse('$_baseUrl/changeset/$changesetId/close'),
              headers: headers,
            )
            .timeout(_timeout);
        if (closeResponse.statusCode < 200 || closeResponse.statusCode >= 300) {
          debugPrint(
            'Aviso: falha ao fechar changeset $changesetId no '
            '${OsmConfig.nomeAmbiente} (${closeResponse.statusCode}).',
          );
        }
      } catch (e) {
        debugPrint(
          'Aviso: erro ao fechar changeset $changesetId no '
          '${OsmConfig.nomeAmbiente}: $e',
        );
      }
    }
  }

  String get _xmlChangeset =>
      '<osm><changeset>'
      '<tag k="created_by" v="Rota do Fabiano/1.0"/>'
      '<tag k="comment" v="Cadastro de local pelo Rota do Fabiano"/>'
      '</changeset></osm>';

  // Monta o XML do ponto que vai ser enviado pro OpenStreetMap com as tags da categoria.
  // Deixado visível para testes unitários garantirem que o escape e as tags estão certos.
  @visibleForTesting
  String montarXmlLugar(LugaresModel lugar, int changesetId) {
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
    if (response.statusCode == 401) {
      throw OsmUnauthorizedException(
        'Sessão do ${OsmConfig.nomeAmbiente} expirada ou revogada ao $operacao.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detalhe = response.body.trim();
      throw Exception(
        'Falha ao $operacao no ${OsmConfig.nomeAmbiente} (${response.statusCode})'
        '${detalhe.isEmpty ? '.' : ': $detalhe'}',
      );
    }
  }
}
