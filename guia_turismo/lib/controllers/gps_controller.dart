// import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:guia_turismo/services/gps_service.dart';

class GpsController extends ChangeNotifier {
  final GpsService _servico = GpsService();

  LatLng? localizacaoAtual;
  List<LatLng> pontos = [];
  bool carregando = false;
  String erro = '';

GpsController() {
    // Inicializa a lista de pontos com a localização atual, se disponível
    obterLocal();
  }

  //Método para obter a localização atual do usuário
  Future<void> obterLocal() async {
    carregando = true;
    notifyListeners();

    try{
      localizacaoAtual = await _servico.obterLocal();
      if (localizacaoAtual == null) {
        erro = "Erro ao obter locaização";
      } else {
        // Adiciona a localização atual à lista de pontos
        pontos.add(localizacaoAtual!);
      }
    } catch (e) {
      erro = e.toString(); // Armazena a mensagem de erro (usar para depuração)
      debugPrint('Erro ao obter localização: $erro'); // Imprime o erro no console para depuração
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}