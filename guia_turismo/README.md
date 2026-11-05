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

## API

O aplicativo usa `https://guiaturismo.onrender.com`:

- `POST /login` para autenticar e obter o token da sessão.
- `GET /lugares` para consultar os lugares.
- `GET /categorias` para carregar as categorias disponíveis no cadastro.
- `POST /lugares` para cadastrar um lugar autenticado.

O mapa usa os tiles do OpenStreetMap e exibe a atribuição aos colaboradores.
A busca de endereço envia uma consulta ao Nominatim; consulte a
[política de uso do Nominatim](https://operations.osmfoundation.org/policies/nominatim/)
antes de aumentar o volume de consultas.

O token e os dados básicos do usuário ficam armazenados localmente para manter
a sessão entre aberturas do aplicativo. A opção **Sair da conta** encerra a
sessão e remove esses dados locais.
