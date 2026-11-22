import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/services/auth_service.dart';
import 'package:guia_turismo/services/lugares_service.dart';
import 'package:guia_turismo/services/osm_service.dart';

class LugaresController extends ChangeNotifier {
  bool carregando = false;
  String erro = '';

  List<LugaresModel> _lugares = [];
  List<LugaresModel> get lugares => _lugares;

  Future<void> listarLugares() async {
    carregando = true;
    erro = '';
    notifyListeners(); // Notifica os ouvintes que o estado mudou

    try {
      final lugaresService = LugaresService();
      _lugares = await lugaresService.buscarLugares();
    } catch (e) {
      erro = 'Erro ao carregar os lugares: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // Método para cadastrar um novo lugar
  Future<String> cadastrarLugar(LugaresModel dados) async {
    carregando = true;
    erro = '';
    notifyListeners();

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw StateError('Faça login com o Google para cadastrar um lugar.');
      }

      final token = await AuthService().autenticarComOSM();
      final idLocal = await OsmService().cadastrarLugar(dados, token);
      return 'Local cadastrado no OpenStreetMap. ID do ponto: $idLocal';
    } catch (e) {
      erro = 'Erro ao cadastrar o lugar: $e';
      return erro;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
