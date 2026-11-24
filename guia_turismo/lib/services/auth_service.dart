import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:guia_turismo/services/osm_config.dart';

class _OsmTokenCache {
  const _OsmTokenCache({required this.accessToken, this.expiresAt});

  final String accessToken;
  final DateTime? expiresAt;

  bool get estaExpirado {
    final limite = expiresAt;
    if (limite == null) return false;
    return DateTime.now().isAfter(limite.subtract(const Duration(seconds: 60)));
  }
}

class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final Map<String, _OsmTokenCache> _tokensPorUsuario = {};

  final AuthorizationServiceConfiguration _serviceConfig =
      const AuthorizationServiceConfiguration(
        authorizationEndpoint: OsmConfig.authorizationEndpoint,
        tokenEndpoint: OsmConfig.tokenEndpoint,
      );

  Future<String> autenticarComOSM({
    required String usuarioUid,
    bool forcarNovoLogin = false,
  }) async {
    if (!forcarNovoLogin) {
      final cache = _tokensPorUsuario[usuarioUid];
      if (cache != null && !cache.estaExpirado) {
        return cache.accessToken;
      }
    }

    final clientId = OsmConfig.clientId.trim();
    if (clientId.isEmpty) {
      throw StateError(
        'Client ID OAuth da sandbox do OpenStreetMap não configurado. '
        'Crie um aplicativo OAuth em https://${OsmConfig.host} com o redirecionamento '
        '${OsmConfig.redirectUrl} e informe o Client ID em lib/services/osm_config.dart '
        '(ou via --dart-define=OSM_CLIENT_ID=...).',
      );
    }

    // Solicita autorização e troca o código recebido por um token de escrita.
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        OsmConfig.redirectUrl,
        serviceConfiguration: _serviceConfig,
        scopes: ['write_api'],
      ),
    );

    final token = result.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError(
        'O ${OsmConfig.nomeAmbiente} não retornou um token de escrita.',
      );
    }

    _tokensPorUsuario[usuarioUid] = _OsmTokenCache(
      accessToken: token,
      expiresAt: result.accessTokenExpirationDateTime,
    );
    return token;
  }

  void limparToken({String? usuarioUid}) {
    if (usuarioUid == null) {
      _tokensPorUsuario.clear();
    } else {
      _tokensPorUsuario.remove(usuarioUid);
    }
  }
}
