import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// Cuida de salvar e ler no próprio celular os lugares que o usuário cadastrou.
class SessionService {
  // Monta uma chave separada por UID pra cada conta enxergar só os seus próprios cadastros.
  String _chaveLugares(String uid) => 'lugares_cadastrados_$uid';

  // Converte a lista de lugares pra texto JSON e salva no SharedPreferences do aparelho.
  Future<void> salvarLugaresCadastrados(
    String uid,
    List<Map<String, dynamic>> lugares,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveLugares(uid), jsonEncode(lugares));
  }

  // Lê o texto JSON salvo no celular e transforma de volta em lista de mapas.
  Future<List<Map<String, dynamic>>> pegarLugaresCadastrados(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveLugares(uid));
    if (dados == null || dados.isEmpty) return [];

    try {
      final decoded = jsonDecode(dados);
      // Garante que o JSON salvo realmente é uma lista antes de tentar ler os itens.
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map((item) {
        return item.map((chave, valor) => MapEntry(chave.toString(), valor));
      }).toList();
    } catch (_) {
      // Se o conteúdo salvo estiver corrompido, devolve lista vazia sem quebrar o app.
      return [];
    }
  }
}
