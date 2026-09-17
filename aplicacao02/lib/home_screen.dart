import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Widget da página de clima - StatefulWidget permite atualizar o estado da tela
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

// Estado da página - gerencia os dados de temperatura e condição do clima
class _WeatherPageState extends State<WeatherPage> {
  // Variáveis que armazenam os dados do clima
  String temperatura = 'Carregando...';
  String condicao = '';

  // Função assíncrona que busca os dados do clima na API WeatherAPI
  Future<void> buscarClima() async {
    const apiKey = 'fe71d2481a264a9fb0501731261308';

    // Monta a URL com a chave da API e a cidade (São Paulo)
    final url = Uri.parse(
      'https://api.weatherapi.com/v1/current.json'
      '?key=$apiKey'
      '&q=Sao Paulo'
      '&lang=pt',
    );

    try {
      // Faz a requisição GET para a API
      final response = await http.get(url);

      // Verifica se a requisição foi bem-sucedida (código 200)
      if (response.statusCode == 200) {
        // Converte a resposta JSON em um Map
        final data = jsonDecode(response.body);

        // Atualiza o estado com os dados do clima
        setState(() {
          temperatura = '${data['current']['temp_c']} °C';
          condicao = data['current']['condition']['text'];
        });
      } else {
        // Tratamento de erro se a requisição falhar
        setState(() {
          temperatura = 'Erro';
          condicao = 'Não foi possível buscar o clima';
        });
      }
    } catch (e) {
      // Captura exceções e exibe a mensagem de erro
      setState(() {
        temperatura = 'Erro';
        condicao = e.toString();
      });
    }
  }

  // Executa quando o widget é criado pela primeira vez
  @override
  void initState() {
    super.initState();
    // Busca o clima automaticamente ao iniciar
    buscarClima();
  }

  // Constrói a interface da tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com título da página
      appBar: AppBar(
        title: const Text('Clima'),
      ),
      // Corpo da página com layout centralizado
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exibe o nome da cidade
            const Text(
              'São Paulo',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Exibe a temperatura atual
            Text(
              temperatura,
              style: const TextStyle(
                fontSize: 50,
              ),
            ),

            const SizedBox(height: 10),

            // Exibe a condição do clima (ensolarado, nublado, etc)
            Text(
              condicao,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 30),

            // Botão para atualizar o clima manualmente
            ElevatedButton(
              onPressed: buscarClima,
              child: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}