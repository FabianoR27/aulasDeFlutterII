// Configurações fixas da sandbox do OpenStreetMap usada pra cadastrar lugares sem mexer no mapa real.
class OsmConfig {
  const OsmConfig._();

  // Endereço da sandbox oficial de testes do OpenStreetMap.
  static const String host = 'master.apis.dev.openstreetmap.org';

  // URL base da API 0.6 da sandbox onde o app cria o changeset e o ponto no mapa.
  static const String apiBaseUrl = 'https://$host/api/0.6';

  // Endereços do OAuth2 da sandbox pra pedir permissão pro usuário e pegar o token.
  static const String authorizationEndpoint = 'https://$host/oauth2/authorize';
  static const String tokenEndpoint = 'https://$host/oauth2/token';

  // Link de retorno cadastrado no app OAuth da sandbox pra voltar pro aplicativo depois do login.
  static const String redirectUrl = 'com.guiaturismo.maps:/oauth2redirect';

  // Client ID do aplicativo OAuth2 criado na sandbox (dá pra sobrescrever via --dart-define se precisar).
  static const String clientId = String.fromEnvironment(
    'OSM_CLIENT_ID',
    defaultValue: 'opFkZC4VwF0OhOKbNXmCGLbrKGqeq1uFOU22mRjJgUQ',
  );

  // Nome mostrado nas mensagens pro usuário saber que o cadastro foi feito na sandbox.
  static const String nomeAmbiente = 'OpenStreetMap (Sandbox)';
}
