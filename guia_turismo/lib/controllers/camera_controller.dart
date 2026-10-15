import 'dart:io';
import '../services/camera_service.dart';
import 'package:flutter/material.dart';

class CameraController extends ChangeNotifier {
  final CameraService _cameraService = CameraService();
  bool carregando = false;
  File? _imagemSelecionada;
  File? get imagemSelecionada => _imagemSelecionada;

  // Método para selecionar uma imagem da galeria
  Future<void> selecionarImagemDaGaleria() async {
    carregando = true;
    notifyListeners();
    _imagemSelecionada = await _cameraService.chamarGaleria();
    carregando = false;
    notifyListeners();
  }

  // Método para tirar uma foto com a câmera
  Future<void> tirarFotoComCamera() async {
    carregando = true;
    notifyListeners();
    _imagemSelecionada = await _cameraService.chamarCamera();
    carregando = false;
    notifyListeners();
  }
}