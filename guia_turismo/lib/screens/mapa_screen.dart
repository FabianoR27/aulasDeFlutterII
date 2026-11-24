import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia_turismo/controllers/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/utils/lugar_helpers.dart';
import 'package:guia_turismo/widgets/foto_lugar.dart';
import 'package:guia_turismo/widgets/lugar_detalhes_sheet.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  @override
  void initState() {
    super.initState();
    // Busca o GPS quando o mapa abre; se estiver desligado ou bloqueado, mostra o atalho pras configurações.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final controller = context.read<LugaresController>();
      final aviso = await controller.iniciarLocalizacao();
      if (aviso != null && mounted) {
        mostrarAvisoLocalizacao(context, controller, aviso);
      }
    });
  }

  // Exibe os lugares cadastrados como marcadores no mapa do OpenStreetMap.
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LugaresController>();
    // Só entra no mapa quem tem latitude e longitude válidas.
    final lugares = controller.lugares.where(_temCoordenadas).toList();

    // Centraliza o mapa na média das coordenadas dos lugares; se não tiver nenhum, centraliza no Brasil.
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
                    // Camada que baixa as imagens de mapa (tiles) do OpenStreetMap.
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.guia_turismo',
                    ),
                    // Camada com os marcadores redondos de cada lugar cadastrado.
                    MarkerLayer(
                      markers: lugares
                          .map(
                            (lugar) => Marker(
                              point: LatLng(lugar.latitude, lugar.longitude),
                              width: 58,
                              height: 58,
                              child: GestureDetector(
                                // Reaproveita o mesmo modal de detalhes usado na tela de lista.
                                onTap: () =>
                                    mostrarDetalhesLugar(context, lugar),
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
                                  // Usa FotoLugar sem fazer leitura síncrona de disco durante o build.
                                  child: ClipOval(
                                    child: FotoLugar(
                                      caminhoFoto: lugar.foto,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    // Se o GPS já achou onde o usuário está, desenha o marcador azul dele no mapa.
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
                // Aviso no topo do mapa caso não exista nenhum lugar válido pra desenhar.
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
                // Créditos obrigatórios dos colaboradores do OpenStreetMap no canto inferior.
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

  // Ignora coordenadas zeradas (0, 0) ou fora dos limites geográficos do planeta.
  bool _temCoordenadas(LugaresModel lugar) {
    return (lugar.latitude != 0 || lugar.longitude != 0) &&
        lugar.latitude >= -90 &&
        lugar.latitude <= 90 &&
        lugar.longitude >= -180 &&
        lugar.longitude <= 180;
  }

  // Caixinha de aviso no mesmo padrão visual escuro do app.
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
