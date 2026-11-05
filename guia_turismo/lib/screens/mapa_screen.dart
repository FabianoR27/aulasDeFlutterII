import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia_turismo/controllers/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  // Exibe os lugares cadastrados como marcadores no mapa do OpenStreetMap.
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LugaresController>();
    final lugares = controller.lugares.where(_temCoordenadas).toList();
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
                              width: 48,
                              height: 54,
                              child: IconButton(
                                tooltip: lugar.nome,
                                onPressed: () =>
                                    _mostrarDetalhes(context, lugar),
                                icon: const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF22D3EE),
                                  size: 42,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFF0B1117),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
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
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
        ),
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
