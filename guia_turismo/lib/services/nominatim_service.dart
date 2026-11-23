import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NominatimService {
  // Guarda o horário da última pesquisa para respeitar o limite do serviço.
  static DateTime? _ultimaConsulta;

  // Consulta o serviço Nominatim por endereço ou CEP e retorna as coordenadas.
  Future<LatLng> buscarCoordenadas(String endereco) async {
    final consulta = endereco.trim();
    if (consulta.isEmpty) {
      throw const FormatException('Informe um endereço ou CEP para pesquisar.');
    }

    await _respeitarIntervaloDeConsulta();
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': consulta,
      'format': 'jsonv2',
      'limit': '1',
    });
    final cabecalhos = {'Accept-Language': 'pt-BR'};
    // Navegadores controlam o User-Agent e enviam o Referer automaticamente.
    if (!kIsWeb) {
      cabecalhos['User-Agent'] = 'RotaCiano/1.0 (aplicativo de guia turistico)';
    }
    final resposta = await http.get(uri, headers: cabecalhos);

    if (resposta.statusCode != 200) {
      throw Exception(
        'A busca de endereço falhou (${resposta.statusCode}). Tente novamente.',
      );
    }

    final dados = jsonDecode(resposta.body);
    if (dados is! List || dados.isEmpty || dados.first is! Map) {
      throw Exception('Nenhum endereço foi encontrado para essa busca.');
    }

    final resultado = dados.first as Map;
    final latitude = double.tryParse(resultado['lat']?.toString() ?? '');
    final longitude = double.tryParse(resultado['lon']?.toString() ?? '');
    if (latitude == null ||
        longitude == null ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw const FormatException(
        'A API retornou coordenadas inválidas para esse endereço.',
      );
    }

    return LatLng(latitude, longitude);
  }

  // Mantém no máximo uma consulta por segundo, conforme a política do Nominatim.
  Future<void> _respeitarIntervaloDeConsulta() async {
    final ultimaConsulta = _ultimaConsulta;
    if (ultimaConsulta != null) {
      final intervalo = DateTime.now().difference(ultimaConsulta);
      if (intervalo < const Duration(seconds: 1)) {
        await Future<void>.delayed(const Duration(seconds: 1) - intervalo);
      }
    }
    _ultimaConsulta = DateTime.now();
  }
}
