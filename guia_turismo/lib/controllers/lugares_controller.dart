import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/services/auth_service.dart';
import 'package:guia_turismo/services/lugares_service.dart';
import 'package:guia_turismo/services/osm_service.dart';
import 'package:guia_turismo/services/session_service.dart';

class LugaresController extends ChangeNotifier {
  // Informa às telas quando uma consulta está em andamento.
  bool carregando = false;
  // Guarda a última mensagem de erro para mostrar ao usuário.
  String erro = '';

  List<LugaresModel> _lugares = [];
  // Permite leitura da lista sem permitir alteração direta por outra tela.
  List<LugaresModel> get lugares => _lugares;

  final Set<int> _favoritos = {};
  Set<int> get favoritos => Set<int>.unmodifiable(_favoritos);

  Position? posicaoUsuario;
  StreamSubscription<Position>? _localizacaoSubscription;

  bool ehFavorito(int lugarId) => _favoritos.contains(lugarId);

  // Mede a distância em linha reta entre o GPS e o local.
  double? distanciaAte(LugaresModel lugar) {
    final posicao = posicaoUsuario;
    if (posicao == null) return null;
    return Geolocator.distanceBetween(
      posicao.latitude,
      posicao.longitude,
      lugar.latitude,
      lugar.longitude,
    );
  }

  // Cada usuário carrega só os próprios favoritos do Firestore.
  Future<void> carregarFavoritos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _favoritos.clear();
      notifyListeners();
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('favoritos')
        .get();
    _favoritos
      ..clear()
      ..addAll(
        snapshot.docs.map((doc) => int.tryParse(doc.id)).whereType<int>(),
      );
    notifyListeners();
  }

  // Grava a mudança na nuvem e atualiza os ícones da tela.
  Future<void> alternarFavorito(LugaresModel lugar) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Faça login para salvar favoritos.');

    final referencia = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('favoritos')
        .doc(lugar.id.toString());

    if (_favoritos.contains(lugar.id)) {
      await referencia.delete();
      _favoritos.remove(lugar.id);
    } else {
      await referencia.set({
        'nome': lugar.nome,
        'categoria': lugar.categoria,
        'latitude': lugar.latitude,
        'longitude': lugar.longitude,
        'descricao': lugar.descricao,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      _favoritos.add(lugar.id);
    }
    notifyListeners();
  }

  // Pede permissão e acompanha novas posições do aparelho.
  Future<String?> iniciarLocalizacao() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return 'Ative o serviço de localização do dispositivo.';
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied) {
      return 'Permissão de localização negada.';
    }
    if (permissao == LocationPermission.deniedForever) {
      return 'A localização está bloqueada. Habilite-a nas configurações.';
    }

    try {
      posicaoUsuario = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      notifyListeners();

      await _localizacaoSubscription?.cancel();
      _localizacaoSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 20,
            ),
          ).listen((posicao) {
            posicaoUsuario = posicao;
            notifyListeners();
          });
      return null;
    } catch (e) {
      return 'Não foi possível obter sua localização: $e';
    }
  }

  Future<void> abrirConfiguracoesLocalizacao() =>
      Geolocator.openLocationSettings();

  @override
  void dispose() {
    _localizacaoSubscription?.cancel();
    super.dispose();
  }

  // Busca os lugares publicados pela API.
  Future<void> listarLugares() async {
    carregando = true;
    erro = '';
    notifyListeners(); // Notifica os ouvintes que o estado mudou

    try {
      final lugaresService = LugaresService();
      final lugaresApi = await lugaresService.buscarLugares();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final lugaresLocais = uid == null
          ? <LugaresModel>[]
          : (await SessionService().pegarLugaresCadastrados(uid))
                .map(LugaresModel.fromJson)
                .toList();

      // Junta os dados da API com os cadastros do usuário sem repetir locais.
      _lugares = [...lugaresApi];
      for (final local in lugaresLocais) {
        final jaExiste = _lugares.any(
          (lugar) =>
              lugar.id == local.id ||
              (lugar.nome == local.nome &&
                  lugar.latitude == local.latitude &&
                  lugar.longitude == local.longitude),
        );
        if (!jaExiste) _lugares.add(local);
      }
      await carregarFavoritos();
    } catch (e) {
      erro = 'Erro ao carregar os lugares: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // Publica o lugar no OpenStreetMap e também o guarda na lista do usuário.
  Future<String> cadastrarLugar(LugaresModel dados) async {
    carregando = true;
    erro = '';
    notifyListeners();

    try {
      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) {
        throw StateError('Faça login com o Google para cadastrar um lugar.');
      }

      final token = await AuthService().autenticarComOSM();
      final idLocal = await OsmService().cadastrarLugar(dados, token);
      final idNumerico =
          int.tryParse(idLocal) ?? -DateTime.now().millisecondsSinceEpoch;
      final lugarCadastrado = LugaresModel(
        id: idNumerico,
        nome: dados.nome,
        categoria: dados.categoria,
        categoriaId: dados.categoriaId,
        latitude: dados.latitude,
        longitude: dados.longitude,
        descricao: dados.descricao,
        foto: dados.foto,
      );

      final sessao = SessionService();
      final locaisSalvos = await sessao.pegarLugaresCadastrados(usuario.uid);
      final jaExiste = locaisSalvos.any((local) {
        final nome = local['nome']?.toString();
        final latitude = double.tryParse(local['latitude']?.toString() ?? '');
        final longitude = double.tryParse(local['longitude']?.toString() ?? '');
        return nome == lugarCadastrado.nome &&
            latitude == lugarCadastrado.latitude &&
            longitude == lugarCadastrado.longitude;
      });
      if (!jaExiste) {
        locaisSalvos.add(lugarCadastrado.toJson());
        await sessao.salvarLugaresCadastrados(usuario.uid, locaisSalvos);
      }

      final jaNaLista = _lugares.any(
        (lugar) =>
            lugar.nome == lugarCadastrado.nome &&
            lugar.latitude == lugarCadastrado.latitude &&
            lugar.longitude == lugarCadastrado.longitude,
      );
      if (!jaNaLista) _lugares = [..._lugares, lugarCadastrado];
      notifyListeners();
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
