import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //==============================
  //Variáveis
  final _cepController = TextEditingController();
  // final _logradouroController = TextEditingController();
  final _ruaController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();

  final String _logradouro = "Os dados do logradouro vão aparecer aqui";

  void exibirDados() async {
    http.Response response = await http.get(
      Uri.parse('https://viacep.com.br/ws/${_cepController.text}/json/'),
    );

    Map<String, dynamic> dados = jsonDecode(response.body);

    _preencherCampos(dados);

    /*setState(() {
      _Logradouro =
          'Local: ${dados['logradouro']} \n Município: ${dados['localidade']} \n Bairro: ${dados['bairro']} \n Estado: ${dados['estado']} \n Sigla: ${dados['uf']}';
    });*/

    debugPrint("Body: ${response.body}");
    debugPrint("Body: ${response.statusCode}");
  }

  void _preencherCampos(Map<String, dynamic> dados) {
    setState(() {
      _ruaController.text = dados['logradouro'];
      _bairroController.text = dados['bairro'];
      _cidadeController.text = dados['localidade'];
      _estadoController.text = dados['estado'];
    });
  }

  //==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Api ViaCep")),
      body: Column(
        children: [
          Text("Digite o seu CEP"),
          // Campo CEP
          SizedBox(height: 20),
          TextField(
            controller: _cepController,
            decoration: InputDecoration(label: Text("Digite o CEP")),
          ),
          SizedBox(height: 20),

          // Rua - Logradouro
          TextField(
            controller: _ruaController,
            decoration: InputDecoration(label: Text("Rua")),
          ),
          SizedBox(height: 20),

          // Bairro
          TextField(
            controller: _bairroController,
            decoration: InputDecoration(label: Text("Bairro")),
          ),
          SizedBox(height: 20),

          TextField(
            controller: _cidadeController,
            decoration: InputDecoration(label: Text("Cidade")),
          ),
          SizedBox(height: 20),

          TextField(
            controller: _estadoController,
            decoration: InputDecoration(label: Text("Estado")),
          ),
          SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              exibirDados();
            },
            child: Text("Buscar"),
          ),
          SizedBox(height: 20),
          Text(_logradouro),
        ],
      ),
    );
  }
}