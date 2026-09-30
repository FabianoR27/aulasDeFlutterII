import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _temaAtual = ThemeMode.light;
  ThemeMode get temaAtual => _temaAtual;

  IconData get iconeAtual => _temaAtual == ThemeMode.light ? Icons.light_mode : Icons.dark_mode;
  
  static ThemeData _mudarTema(Brightness brilho) {
    final cor = ColorScheme.fromSeed(
      seedColor: Colors.pink, 
      brightness: brilho
    );

    return ThemeData(
      primarySwatch: Colors.pink,
      colorScheme: cor,
    
      appBarTheme: AppBarTheme(
        backgroundColor: cor.primary,
        foregroundColor: cor.onPrimary,
        elevation: 4,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cor.primary,
        selectedItemColor: cor.onPrimary,
        elevation: 4,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cor.primary,
        foregroundColor: cor.onPrimary,
      ),

    );  //notifierlisteners()
  }

    ThemeData temaClaro() => _mudarTema(Brightness.light);
    ThemeData temaEscuro() => _mudarTema(Brightness.dark);

    void alternarTema() {
      _temaAtual = _temaAtual == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      notifyListeners(); // avisa a tela que atualizou
    }

}