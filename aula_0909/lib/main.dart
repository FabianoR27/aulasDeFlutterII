import 'package:aula_0909/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de Contatos',
      home: const HomeScreen(),
    ),
  );
}
