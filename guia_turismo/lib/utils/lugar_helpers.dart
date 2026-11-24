import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:url_launcher/url_launcher.dart';

// Formata a distância pra ficar fácil de ler (em metros se for perto, ou km se for longe).
String formatarDistancia(double metros) {
  if (metros < 1000) return '${metros.round()} m';
  return '${(metros / 1000).toStringAsFixed(1)} km';
}

// Filtra a lista de lugares pelo texto da busca e pelo filtro de favoritos.
List<LugaresModel> filtrarLugares(
  List<LugaresModel> lugares, {
  required String busca,
  required bool somenteFavoritos,
  required bool Function(int id) ehFavorito,
}) {
  final termo = busca.trim().toLowerCase();

  return lugares.where((lugar) {
    // Se o usuário marcou "Favoritos", só deixa passar quem está favoritado.
    final correspondeFavorito = !somenteFavoritos || ehFavorito(lugar.id);
    // Procura o texto digitado no nome do lugar ou na categoria dele.
    final correspondeBusca =
        termo.isEmpty ||
        lugar.nome.toLowerCase().contains(termo) ||
        (lugar.categoria?.toLowerCase().contains(termo) ?? false);
    return correspondeFavorito && correspondeBusca;
  }).toList();
}

// Transforma erros técnicos do Dart/rede em mensagens mais simples pro usuário entender.
String mensagemErroAmigavel(
  Object erro, {
  String fallback = 'Ocorreu um erro inesperado. Tente novamente.',
}) {
  if (erro is SocketException) {
    return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
  }
  if (erro is TimeoutException) {
    return 'O servidor demorou para responder. Tente novamente em instantes.';
  }
  if (erro is FormatException) {
    return erro.message.isNotEmpty
        ? erro.message
        : 'Recebemos uma resposta inválida do servidor.';
  }
  if (erro is StateError) {
    return erro.message.isNotEmpty ? erro.message : fallback;
  }

  // Limpa prefixos técnicos tipo "Exception:" que costumam aparecer no texto do erro.
  final texto = erro
      .toString()
      .replaceAll('Exception: ', '')
      .replaceFirst('Bad state: ', '')
      .trim();

  if (texto.isEmpty) return fallback;
  return texto;
}

// Abre o Google Maps fora do app já traçando a rota até o lugar escolhido.
Future<void> abrirRotasNoMapa(BuildContext context, LugaresModel lugar) async {
  // Monta a latitude e longitude no formato que a URL do Google Maps espera.
  final destino =
      '${lugar.latitude.toStringAsFixed(6)},${lugar.longitude.toStringAsFixed(6)}';
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$destino&travelmode=driving',
  );

  // Tenta abrir no aplicativo externo de mapas; se não conseguir, avisa na tela.
  final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!abriu && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível abrir o aplicativo de mapas.'),
      ),
    );
  }
}

// Mostra uma SnackBar de aviso do GPS e, quando faz sentido, coloca um botão pras configurações.
void mostrarAvisoLocalizacao(
  BuildContext context,
  LugaresController controller,
  String aviso,
) {
  final messenger = ScaffoldMessenger.of(context);
  final precisaAbrirApp = aviso.toLowerCase().contains('bloqueada');
  final precisaAtivarGps = aviso.toLowerCase().contains('ative o serviço');

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(aviso),
      // Se o GPS estiver desligado ou a permissão bloqueada, já dá um atalho pro usuário arrumar.
      action: (precisaAbrirApp || precisaAtivarGps)
          ? SnackBarAction(
              label: 'Configurações',
              onPressed: () {
                if (precisaAbrirApp) {
                  controller.abrirConfiguracoesApp();
                } else {
                  controller.abrirConfiguracoesLocalizacao();
                }
              },
            )
          : null,
    ),
  );
}
