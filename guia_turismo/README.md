# Rota do Fabiano

Aplicativo Flutter para descobrir, cadastrar e explorar lugares turísticos.
O app reúne destinos da API do Guia de Turismo e locais cadastrados pelo
usuário, com mapa, GPS, favoritos e navegação externa.

## Funcionalidades

- Login com Google usando Firebase Authentication.
- Busca de lugares por nome ou categoria.
- Cadastro de locais com nome, categoria, descrição, coordenadas e foto.
- Busca de coordenadas por endereço ou CEP usando o Nominatim.
- Mapa OpenStreetMap com marcadores dos lugares, fotos e posição atual do
  usuário.
- Exibição da distância aproximada entre o usuário e cada lugar.
- Favoritos associados à conta autenticada e armazenados no Cloud Firestore.
- Abertura de rotas no Google Maps.
- Armazenamento local dos lugares cadastrados, separado pelo UID do usuário,
  usando `SharedPreferences`.

## Executar

```bash
flutter pub get
flutter run
```

## Serviços e dados

- A API `https://guiaturismo.onrender.com` fornece os lugares e as categorias.
  Os locais cadastrados pelo usuário também são salvos no dispositivo e
  adicionados à lista.
- O login usa Firebase Authentication e o login Google.
- O Cloud Firestore armazena os favoritos por usuário.
- Para publicar um local no OpenStreetMap, o app solicita autorização OAuth
  com permissão `write_api`.
- O mapa carrega tiles do OpenStreetMap e exibe atribuição aos colaboradores.
- A busca de endereço usa o Nominatim. Consulte a
  [política de uso do Nominatim](https://operations.osmfoundation.org/policies/nominatim/)
  antes de aumentar o volume de consultas.
- As rotas são abertas externamente no Google Maps.

## Configuração OAuth do OpenStreetMap (Sandbox)

O cadastro de locais usa exclusivamente a sandbox oficial do OpenStreetMap
(`https://master.apis.dev.openstreetmap.org/`), evitando publicar dados de teste
no mapa real.

1. Crie uma conta na sandbox (`https://master.apis.dev.openstreetmap.org/`).
2. Cadastre um aplicativo OAuth2 com a permissão `write_api` e o endereço de
   retorno `com.guiaturismo.maps:/oauth2redirect`.
3. Informe o Client ID gerado em `lib/services/osm_config.dart` ou passe-o ao
   executar o aplicativo:

```bash
flutter run --dart-define=OSM_CLIENT_ID=SEU_CLIENT_ID_DA_SANDBOX
```
