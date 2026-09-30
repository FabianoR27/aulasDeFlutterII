import 'package:flutter/material.dart';
import 'package:guia_turismo/screens/home_screen.dart';

class Inicializar extends StatelessWidget {
  const Inicializar({super.key});

  @override
  Widget build(BuildContext context) {
    // consumer()
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'home',
      routes: {
        'home': (context) => const HomeScreen(),
        // 'login': (context) => const LoginScreen(),

      },
      title: 'Guia Turismo',
      home: const HomeScreen(),
    );
  }
}