import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/utils/lugar_helpers.dart';
import 'package:guia_turismo/widgets/foto_lugar.dart';
import 'package:provider/provider.dart';

// Abre a janelinha de baixo (BottomSheet) com os detalhes completos do lugar.
// Usada tanto quando o usuário toca num card da lista quanto num pin do mapa.
void mostrarDetalhesLugar(BuildContext context, LugaresModel lugar) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF111B24),
    showDragHandle: true,
    // Deixa o modal crescer e rolar se a descrição for grande ou a tela for pequena.
    isScrollControlled: true,
    builder: (sheetContext) => _LugarDetalhesSheet(lugar: lugar),
  );
}

class _LugarDetalhesSheet extends StatelessWidget {
  const _LugarDetalhesSheet({required this.lugar});

  final LugaresModel lugar;

  // Favorita ou desfavorita o lugar e avisa se der algum problema no Firestore.
  Future<void> _alternarFavorito(
    BuildContext context,
    LugaresController controller,
  ) async {
    try {
      await controller.alternarFavorito(lugar);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensagemErroAmigavel(
              e,
              fallback: 'Não foi possível atualizar os favoritos.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // O Consumer escuta mudanças no controller pra atualizar o coração e a distância na hora.
    return Consumer<LugaresController>(
      builder: (context, controller, _) {
        final distancia = controller.distanciaAte(lugar);
        final favorito = controller.ehFavorito(lugar.id);
        final alturaMaxima = MediaQuery.sizeOf(context).height * 0.82;

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: alturaMaxima),
            // SingleChildScrollView evita erro de overflow se o texto da descrição for comprido.
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Só mostra a área de foto se o lugar realmente tiver uma imagem cadastrada.
                  if (lugar.foto?.trim().isNotEmpty == true) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 170,
                        width: double.infinity,
                        child: FotoLugar(
                          caminhoFoto: lugar.foto,
                          iconePadrao: Icons.broken_image_outlined,
                          corIconePadrao: const Color(0xFF94A3B8),
                          tamanhoIcone: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Nome principal do ponto turístico.
                  Text(
                    lugar.nome,
                    style: const TextStyle(
                      color: Color(0xFFF1F5F9),
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Categoria em destaque na cor ciano do app.
                  Text(
                    lugar.categoria?.isNotEmpty == true
                        ? lugar.categoria!
                        : 'Sem categoria',
                    style: const TextStyle(color: Color(0xFF22D3EE)),
                  ),
                  // Descrição do lugar (agora aparece tanto na lista quanto no mapa).
                  if (lugar.descricao.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      lugar.descricao,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  // Mostra a latitude e longitude formatadas com 5 casas decimais.
                  Row(
                    children: [
                      const Icon(
                        Icons.my_location_rounded,
                        size: 18,
                        color: Color(0xFF22D3EE),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${lugar.latitude.toStringAsFixed(5)}, '
                        '${lugar.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  // Se o GPS já tiver a posição do usuário, mostra a distância aproximada.
                  if (distancia != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Distância aproximada: ${formatarDistancia(distancia)}',
                      style: const TextStyle(color: Color(0xFFCBD5E1)),
                    ),
                  ],
                  const SizedBox(height: 18),
                  // Barra final com botão de favoritar e botão para abrir a rota no Google Maps.
                  Row(
                    children: [
                      IconButton(
                        tooltip: favorito
                            ? 'Remover dos favoritos'
                            : 'Adicionar aos favoritos',
                        onPressed: () => _alternarFavorito(context, controller),
                        icon: Icon(
                          favorito
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: const Color(0xFFFF6B81),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => abrirRotasNoMapa(context, lugar),
                          icon: const Icon(Icons.directions_rounded),
                          label: const Text('Como chegar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
