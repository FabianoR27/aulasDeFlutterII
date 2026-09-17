import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:atividade03/models/cep_model.dart';

class CepService {
  Future<CepModel> buscarCep(String cep) async {
    String url = "https://viacep.com.br/ws/$cep/json/";
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> dados = jsonDecode(response.body);
      return CepModel.fromJson(dados);
    } else {
      throw Exception('Falha ao buscar CEP');
    }
  }

}