# Rota Ciano

Aplicativo Flutter de guia de turismo. Após entrar com uma conta existente, é
possível consultar os lugares publicados pela API, pesquisar por nome ou
categoria, ver descrição e coordenadas, atualizar a lista e cadastrar novos
destinos. O mapa mostra os lugares que possuem coordenadas e permite consultar
seus detalhes. No cadastro, um endereço ou CEP pode ser convertido em
coordenadas pela API Nominatim do OpenStreetMap. A interface usa tema escuro
com ciano como cor de destaque.

## Executar

```bash
flutter pub get
flutter run
```

## Dados e autenticação

O aplicativo usa `https://guiaturismo.onrender.com`:

- `GET /lugares` para consultar os lugares exibidos na lista.
- `GET /categorias` para carregar as categorias disponíveis no cadastro.

O login do aplicativo continua sendo feito pelo Google/Firebase. Para cadastrar
um local no OpenStreetMap, o aplicativo também solicita autorização da conta
OSM com permissão de escrita (`write_api`). O cadastro cria um ponto no
OpenStreetMap; ele não é enviado para a API do Guia de Turismo nem aparece na
lista carregada por essa API.

O mapa usa os tiles do OpenStreetMap e exibe a atribuição aos colaboradores.
A busca de endereço envia uma consulta ao Nominatim; consulte a
[política de uso do Nominatim](https://operations.osmfoundation.org/policies/nominatim/)
antes de aumentar o volume de consultas.

O identificador do app e o endereço de retorno OAuth precisam estar cadastrados
nas configurações do aplicativo OAuth no OpenStreetMap. O endereço usado é
`com.guiaturismo.maps:/oauth2redirect`.
