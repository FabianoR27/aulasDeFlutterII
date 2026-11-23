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

## Configuração OAuth do OpenStreetMap

O identificador do app e o endereço de retorno precisam estar cadastrados nas
configurações do aplicativo OAuth no OpenStreetMap. O endereço usado é
`com.guiaturismo.maps:/oauth2redirect`.
