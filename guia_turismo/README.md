# Rota Ciano

Aplicativo Flutter de guia de turismo. Após entrar com uma conta existente, é
possível consultar os lugares publicados pela API, pesquisar por nome ou
categoria, ver descrição e coordenadas, atualizar a lista e cadastrar novos
destinos. A interface usa tema escuro com ciano como cor de destaque.

## Executar

```bash
flutter pub get
flutter run
```

## API

O aplicativo usa `https://guiaturismo.onrender.com`:

- `POST /login` para autenticar e obter o token da sessão.
- `GET /lugares` para consultar os lugares.
- `POST /lugares` para cadastrar um lugar autenticado.

O token e os dados básicos do usuário ficam armazenados localmente para manter
a sessão entre aberturas do aplicativo. A opção **Sair da conta** encerra a
sessão e remove esses dados locais.
