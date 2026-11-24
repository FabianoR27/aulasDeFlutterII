class OsmConfig {
  const OsmConfig._();

  // Usa a sandbox oficial do OpenStreetMap por padrão para evitar dados de teste
  // no mapa real. Para apontar para produção, rode com:
  // --dart-define=OSM_USE_PRODUCTION=true
  static const bool usarProducao = bool.fromEnvironment(
    'OSM_USE_PRODUCTION',
    defaultValue: false,
  );

  static const String host = usarProducao
      ? 'www.openstreetmap.org'
      : 'master.apis.dev.openstreetmap.org';

  static const String apiBaseUrl = usarProducao
      ? 'https://api.openstreetmap.org/api/0.6'
      : 'https://master.apis.dev.openstreetmap.org/api/0.6';

  static const String authorizationEndpoint = 'https://$host/oauth2/authorize';
  static const String tokenEndpoint = 'https://$host/oauth2/token';

  static const String redirectUrl = 'com.guiaturismo.maps:/oauth2redirect';

  // Client ID do aplicativo OAuth2 criado na sandbox
  // (https://master.apis.dev.openstreetmap.org).
  // Você pode preencher o defaultValue abaixo ou passar em tempo de execução:
  // --dart-define=OSM_CLIENT_ID=SEU_CLIENT_ID_DA_SANDBOX
  static const String _clientIdSandbox = String.fromEnvironment(
    'OSM_CLIENT_ID',
    defaultValue: 'opFkZC4VwF0OhOKbNXmCGLbrKGqeq1uFOU22mRjJgUQ',
  );

  static const String _clientIdProducao = String.fromEnvironment(
    'OSM_PROD_CLIENT_ID',
    defaultValue: 'FsjB0m9plLoZYIZWLRO-8RnuKcNtDr_HXDJ2bM-HAMU',
  );

  static String get clientId =>
      usarProducao ? _clientIdProducao : _clientIdSandbox;

  static String get nomeAmbiente =>
      usarProducao ? 'OpenStreetMap' : 'OpenStreetMap (Sandbox)';
}
