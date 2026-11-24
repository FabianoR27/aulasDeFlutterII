import 'dart:io';

import 'package:flutter/material.dart';

// Widget reaproveitado na lista e no mapa pra exibir a foto do lugar (da internet ou do celular).
class FotoLugar extends StatelessWidget {
  const FotoLugar({
    super.key,
    required this.caminhoFoto,
    this.fit = BoxFit.cover,
    this.iconePadrao = Icons.location_on_rounded,
    this.corIconePadrao = const Color(0xFF22D3EE),
    this.tamanhoIcone = 34,
  });

  final String? caminhoFoto;
  final BoxFit fit;
  final IconData iconePadrao;
  final Color corIconePadrao;
  final double tamanhoIcone;

  // Monta um quadradinho padrão caso o lugar não tenha foto ou a imagem dê erro ao carregar.
  Widget _placeholder(IconData icone, Color cor) {
    return Container(
      color: const Color(0xFF1E2C38),
      alignment: Alignment.center,
      child: Icon(icone, color: cor, size: tamanhoIcone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foto = caminhoFoto?.trim() ?? '';

    // Se não tiver foto cadastrada, mostra logo o ícone padrão.
    if (foto.isEmpty) {
      return _placeholder(iconePadrao, corIconePadrao);
    }

    // Se começar com http/https, carrega a imagem direto da internet.
    if (foto.startsWith('http://') || foto.startsWith('https://')) {
      return Image.network(
        foto,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(
          Icons.broken_image_outlined,
          const Color(0xFF94A3B8),
        ),
      );
    }

    // Se for caminho local do aparelho, carrega sem checar o disco de forma síncrona no build.
    // Caso o arquivo tenha sido apagado, o errorBuilder mostra o ícone padrão sem travar a tela.
    return Image.file(
      File(foto),
      fit: fit,
      errorBuilder: (_, _, _) => _placeholder(iconePadrao, corIconePadrao),
    );
  }
}
