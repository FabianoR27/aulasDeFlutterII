import 'package:flutter_appauth/flutter_appauth.dart';

class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  // Dados gerados no OpenStreetMap
  final String _clientId = 'FsjB0m9plLoZYIZWLRO-8RnuKcNtDr_HXDJ2bM-HAMU';
  final String _redirectUrl = 'com.guiaturismo.maps:/oauth2redirect';

  // Endpoints oficiais do OpenStreetMap
  final AuthorizationServiceConfiguration _serviceConfig =
      const AuthorizationServiceConfiguration(
        authorizationEndpoint: 'https://www.openstreetmap.org/oauth2/authorize',
        tokenEndpoint: 'https://www.openstreetmap.org/oauth2/token',
      );

  Future<String> autenticarComOSM() async {
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        _clientId,
        _redirectUrl,
        serviceConfiguration: _serviceConfig,
        scopes: ['write_api'],
      ),
    );

    final token = result.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('O OpenStreetMap não retornou um token de escrita.');
    }

    return token;
  }
}
