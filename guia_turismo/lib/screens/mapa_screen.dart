import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia_turismo/controllers/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  @override
  void initState() {
    super.initState();
    // Busca o GPS quando a tela abre para mostrar a posição no mapa.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<LugaresController>();
      final aviso = await controller.iniciarLocalizacao();
      if (aviso != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(aviso)));
      }
    });
  }

  // Exibe os lugares cadastrados como marcadores no mapa do OpenStreetMap.
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LugaresController>();
    final lugares = controller.lugares.where(_temCoordenadas).toList();
    // Centraliza o mapa nos lugares cadastrados; se estiver vazio, usa o Brasil.
    final centro = lugares.isEmpty
        ? const LatLng(-14.2350, -51.9253)
        : LatLng(
            lugares.map((lugar) => lugar.latitude).reduce((a, b) => a + b) /
                lugares.length,
            lugares.map((lugar) => lugar.longitude).reduce((a, b) => a + b) /
                lugares.length,
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de lugares')),
      body: controller.carregando && controller.lugares.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF22D3EE)),
            )
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: centro,
                    initialZoom: lugares.length == 1 ? 12 : 4.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.guia_turismo',
                    ),
                    MarkerLayer(
                      markers: lugares
                          .map(
                            (lugar) => Marker(
                              point: LatLng(lugar.latitude, lugar.longitude),
                              width: 58,
                              height: 58,
                              child: GestureDetector(
                                onTap: () => _mostrarDetalhes(context, lugar),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22D3EE),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFF1F5F9),
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x660B1117),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _fotoLugar(lugar, fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (controller.posicaoUsuario != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              controller.posicaoUsuario!.latitude,
                              controller.posicaoUsuario!.longitude,
                            ),
                            width: 48,
                            height: 48,
                            child: const Icon(
                              Icons.my_location_rounded,
                              color: Color(0xFF38BDF8),
                              size: 34,
                              shadows: [
                                Shadow(color: Color(0xFF0B1117), blurRadius: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (lugares.isEmpty)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: _aviso(
                      controller.erro.isEmpty
                          ? 'Ainda não há lugares com coordenadas para mostrar.'
                          : 'Não foi possível carregar os lugares: ${controller.erro}',
                    ),
                  ),
                const Positioned(
                  left: 8,
                  bottom: 8,
                  child: SafeArea(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xDD0B1117),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: Text(
                          '© OpenStreetMap contributors',
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Ignora coordenadas ausentes ou fora dos limites geográficos válidos.
  bool _temCoordenadas(LugaresModel lugar) {
    return (lugar.latitude != 0 || lugar.longitude != 0) &&
        lugar.latitude >= -90 &&
        lugar.latitude <= 90 &&
        lugar.longitude >= -180 &&
        lugar.longitude <= 180;
  }

  // Abre os dados básicos do lugar selecionado no marcador.
  void _mostrarDetalhes(BuildContext context, LugaresModel lugar) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111B24),
      showDragHandle: true,
      builder: (sheetContext) => Consumer<LugaresController>(
        builder: (context, controller, _) {
          final distancia = controller.distanciaAte(lugar);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lugar.foto?.isNotEmpty == true) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: _fotoLugar(lugar, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    lugar.nome,
                    style: const TextStyle(
                      color: Color(0xFFF1F5F9),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lugar.categoria?.isNotEmpty == true
                        ? lugar.categoria!
                        : 'Sem categoria',
                    style: const TextStyle(color: Color(0xFF22D3EE)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${lugar.latitude.toStringAsFixed(5)}, '
                    '${lugar.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  if (distancia != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Distância aproximada: ${_formatarDistancia(distancia)}',
                      style: const TextStyle(color: Color(0xFFCBD5E1)),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      IconButton(
                        tooltip: controller.ehFavorito(lugar.id)
                            ? 'Remover dos favoritos'
                            : 'Adicionar aos favoritos',
                        onPressed: () =>
                            _alternarFavorito(context, controller, lugar),
                        icon: Icon(
                          controller.ehFavorito(lugar.id)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: const Color(0xFFFF6B81),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _abrirRotas(lugar),
                          icon: const Icon(Icons.directions_rounded),
                          label: const Text('Como chegar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _alternarFavorito(
    BuildContext context,
    LugaresController controller,
    LugaresModel lugar,
  ) async {
    try {
      await controller.alternarFavorito(lugar);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _abrirRotas(LugaresModel lugar) async {
    final destino =
        '${lugar.latitude.toStringAsFixed(6)},${lugar.longitude.toStringAsFixed(6)}';
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destino&travelmode=driving',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o aplicativo de mapas.'),
          ),
        );
      }
    }
  }

  String _formatarDistancia(double metros) {
    if (metros < 1000) return '${metros.round()} m';
    return '${(metros / 1000).toStringAsFixed(1)} km';
  }

  Widget _fotoLugar(LugaresModel lugar, {required BoxFit fit}) {
    final foto = lugar.foto?.trim();
    if (foto == null || foto.isEmpty) {
      return Container(
        color: const Color(0xFF1E2C38),
        alignment: Alignment.center,
        child: const Icon(
          Icons.location_on_rounded,
          color: Color(0xFF22D3EE),
          size: 34,
        ),
      );
    }

    if (foto.startsWith('http://') || foto.startsWith('https://')) {
      // Fotos da API são carregadas pela internet; as demais usam arquivo local.
      return Image.network(
        foto,
        fit: fit,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8)),
      );
    }

    final arquivo = File(foto);
    if (arquivo.existsSync()) {
      return Image.file(arquivo, fit: fit);
    }

    return Container(
      color: const Color(0xFF1E2C38),
      alignment: Alignment.center,
      child: const Icon(
        Icons.location_on_rounded,
        color: Color(0xFF22D3EE),
        size: 34,
      ),
    );
  }

  // Mantém mensagens de estado no mesmo padrão visual do aplicativo.
  Widget _aviso(String mensagem) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111B24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF253442)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(mensagem, style: const TextStyle(color: Color(0xFFCBD5E1))),
      ),
    );
  }
}
