import 'dart:io';

import '../services/camera_service.dart';

import 'package:flutter/material.dart';

class CameraController extends ChangeNotifier {
  final CameraService _cameraService = CameraService();
  bool carregando = false;
  File? _imagemSelecionada;
  // Entrega a foto selecionada para a tela.
  File? get imagemSelecionada => _imagemSelecionada;

  // Escolhe uma imagem da galeria.
  Future<void> selecionarImagemDaGaleria() async {
    carregando = true;
    notifyListeners();
    _imagemSelecionada = await _cameraService.chamarGaleria();
    carregando = false;
    notifyListeners();
  }

  // Abre a câmera para tirar uma foto.
  Future<void> tirarFotoComCamera() async {
    carregando = true;
    notifyListeners();
    _imagemSelecionada = await _cameraService.chamarCamera();
    carregando = false;
    notifyListeners();
  }
}
