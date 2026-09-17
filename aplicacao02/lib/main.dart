// Importa o package do Flutter e a página de clima
import 'package:aplicacao01/home_screen.dart';
import 'package:flutter/material.dart';

// Função principal que executa o app
void main() {
  runApp(const MyApp());
}

// Widget raiz da aplicação
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsão do Clima',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Usa WeatherPage como tela principal
      home: const WeatherPage(),
    );
  }
}