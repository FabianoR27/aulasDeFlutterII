import 'dart:convert';

// import 'package:secure_shared_preferences/secure_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*class SessionService {
  Future<void> salvarToken(String token) async {
    final prefs = await SecureSharedPref.getInstance();
    await prefs.putString('token', token, isEncrypted: true);
  }

  Future<String?> pegarToken() async {
    final prefs = await SecureSharedPref.getInstance();
    return prefs.getString('token', isEncrypted: true);
  }

  Future<void> logout() async {
    final prefs = await SecureSharedPref.getInstance();
    await prefs.clearAll();
  }
}*/
class SessionService {
  static String nome = '';
  static String email = '';

  // Uma chave por conta evita misturar os locais de usuários diferentes.
  String _chaveLugares(String uid) => 'lugares_cadastrados_$uid';

  // SharedPreferences guarda os locais como texto JSON no próprio aparelho.
  Future<void> salvarLugaresCadastrados(
    String uid,
    List<Map<String, dynamic>> lugares,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveLugares(uid), jsonEncode(lugares));
  }

  // Lê o JSON e devolve a lista pronta para virar objetos LugaresModel.
  Future<List<Map<String, dynamic>>> pegarLugaresCadastrados(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveLugares(uid));
    if (dados == null || dados.isEmpty) return [];

    try {
      final decoded = jsonDecode(dados);
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map((item) {
        return item.map((chave, valor) => MapEntry(chave.toString(), valor));
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<String> pegarNome() async {
    final prefs = await SharedPreferences.getInstance();
    nome = prefs.getString('nome') ?? '';
    return nome;
  }

  Future<String> pegarEmail() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    return email;
  }

  Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> pegarToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> salvarUsuario(Map user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', user['email']);
    await prefs.setString('nome', user['nome']);
  }
}
