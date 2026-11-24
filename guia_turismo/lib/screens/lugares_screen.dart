import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/auth_controller.dart';
import 'package:guia_turismo/controllers/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/screens/cadastrar_lugar_screen.dart';
import 'package:guia_turismo/screens/mapa_screen.dart';
import 'package:guia_turismo/utils/lugar_helpers.dart';
import 'package:guia_turismo/widgets/lugar_detalhes_sheet.dart';
import 'package:provider/provider.dart';

class LugaresScreen extends StatefulWidget {
  const LugaresScreen({super.key});

  @override
  State<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends State<LugaresScreen> {
  // Texto digitado pelo usuário para filtrar a lista.
  String _busca = '';
  // Controla se a tela mostra todos os lugares ou só os favoritados.
  bool _somenteFavoritos = false;

  @override
  void initState() {
    super.initState();
    // Assim que a tela termina de montar, já busca os lugares e liga o GPS.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final controller = context.read<LugaresController>();
      controller.listarLugares();

      // Pede a localização do aparelho e avisa o usuário se o GPS estiver desligado/bloqueado.
      final aviso = await controller.iniciarLocalizacao();
      if (aviso != null && mounted) {
        mostrarAvisoLocalizacao(context, controller, aviso);
      }
    });
  }

  // Abre a tela de cadastro e, se um novo lugar foi salvo, recarrega a lista.
  Future<void> _abrirCadastro() async {
    final cadastrado = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const CadastrarLugarScreen()),
    );
    if (!mounted) return;
    if (cadastrado == true) {
      await context.read<LugaresController>().listarLugares();
    }
  }

  // Abre o mapa com os lugares já carregados pelo controller.
  void _abrirMapa() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const MapaScreen()));
  }

  // Desloga a conta do Google/Firebase e mostra um aviso amigável caso dê erro.
  Future<void> _sair() async {
    try {
      await context.read<AuthController>().deslogarUsuario();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensagemErroAmigavel(
              e,
              fallback: 'Não foi possível encerrar a sessão.',
            ),
          ),
        ),
      );
    }
  }

  // Marca ou desmarca o lugar como favorito no Firestore.
  Future<void> _alternarFavorito(
    LugaresController controller,
    LugaresModel lugar,
  ) async {
    try {
      await controller.alternarFavorito(lugar);
    } catch (e) {
      if (!mounted) return;
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

  // Monta cada card da lista usando o controller que o build já está escutando
  // (evita chamar context.watch de novo pra cada item da lista).
  Widget _buildLugarCard(LugaresController controller, LugaresModel lugar) {
    final distancia = controller.distanciaAte(lugar);
    final favorito = controller.ehFavorito(lugar.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF111B24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF1E2C38)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        // Ao tocar no card, abre o modal compartilhado com todos os detalhes do lugar.
        onTap: () => mostrarDetalhesLugar(context, lugar),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone lateral do pin com fundo ciano suave.
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF22D3EE),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              // Coluna central com nome, categoria, resumo da descrição e distância.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lugar.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF1F5F9),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lugar.categoria?.isNotEmpty == true
                          ? lugar.categoria!
                          : 'Sem categoria',
                      style: const TextStyle(
                        color: Color(0xFF22D3EE),
                        fontSize: 13,
                      ),
                    ),
                    if (lugar.descricao.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        lugar.descricao,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (distancia != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'A ${formatarDistancia(distancia)}',
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Botão de coração pra favoritar direto no card sem precisar abrir os detalhes.
              IconButton(
                tooltip: favorito
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
                onPressed: () => _alternarFavorito(controller, lugar),
                icon: Icon(
                  favorito
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: const Color(0xFFFF6B81),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tela de aviso padrão pra quando não tem resultado, favoritos ou deu erro na API.
  Widget _estadoVazio({
    required IconData icone,
    required String titulo,
    required String mensagem,
    Widget? acao,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 320,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icone, color: const Color(0xFF22D3EE), size: 44),
                  const SizedBox(height: 16),
                  Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF1F5F9),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mensagem,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      height: 1.4,
                    ),
                  ),
                  if (acao != null) ...[const SizedBox(height: 18), acao],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o controller uma única vez aqui no build principal.
    final controller = context.watch<LugaresController>();
    final nome =
        context.watch<AuthController>().usuario?.displayName?.trim() ?? '';

    // Usa a função auxiliar pra filtrar por nome/categoria e por favoritos.
    final lugaresFiltrados = filtrarLugares(
      controller.lugares,
      busca: _busca,
      somenteFavoritos: _somenteFavoritos,
      ehFavorito: controller.ehFavorito,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.explore_rounded, color: Color(0xFF22D3EE), size: 24),
            SizedBox(width: 9),
            Text(
              'Rota do Fabiano',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ver mapa',
            onPressed: _abrirMapa,
            icon: const Icon(Icons.map_outlined),
          ),
          IconButton(
            tooltip: 'Sair da conta',
            onPressed: _sair,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        backgroundColor: const Color(0xFF22D3EE),
        foregroundColor: const Color(0xFF06232B),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Novo lugar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com saudação, campo de busca e filtros "Todos" / "Favoritos".
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome.isEmpty ? 'Descubra novos lugares' : 'Olá, $nome',
                    style: const TextStyle(
                      color: Color(0xFFF1F5F9),
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Inspire-se para a sua próxima aventura.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (value) => setState(() => _busca = value),
                    decoration: const InputDecoration(
                      hintText: 'Buscar por lugar ou categoria',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Todos'),
                        selected: !_somenteFavoritos,
                        onSelected: (_) =>
                            setState(() => _somenteFavoritos = false),
                      ),
                      ChoiceChip(
                        label: const Text('Favoritos'),
                        selected: _somenteFavoritos,
                        avatar: const Icon(Icons.favorite_rounded, size: 16),
                        onSelected: (_) =>
                            setState(() => _somenteFavoritos = true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Linha com o título da seção e o total de locais encontrados.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _somenteFavoritos
                          ? 'Lugares favoritos'
                          : 'Lugares para explorar',
                      style: const TextStyle(
                        color: Color(0xFFF1F5F9),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${lugaresFiltrados.length} locais',
                    style: const TextStyle(
                      color: Color(0xFF22D3EE),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Se deu erro ao recarregar mas já tinha lugares na tela, mostra um banner discreto.
            if (controller.erro.isNotEmpty && controller.lugares.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Material(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFFF9B9B),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            controller.erro,
                            style: const TextStyle(
                              color: Color(0xFFFFB4B4),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Tentar novamente',
                          onPressed: controller.listarLugares,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Color(0xFFFFB4B4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Lista principal com puxar pra atualizar (pull-to-refresh).
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF22D3EE),
                backgroundColor: const Color(0xFF111B24),
                onRefresh: controller.listarLugares,
                child: controller.carregando && controller.lugares.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF22D3EE),
                        ),
                      )
                    : controller.erro.isNotEmpty && controller.lugares.isEmpty
                    ? _estadoVazio(
                        icone: Icons.cloud_off_rounded,
                        titulo: 'Não foi possível carregar',
                        mensagem: controller.erro,
                        acao: OutlinedButton.icon(
                          onPressed: controller.listarLugares,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Tentar novamente'),
                        ),
                      )
                    : lugaresFiltrados.isEmpty
                    ? _estadoVazio(
                        icone: _somenteFavoritos
                            ? Icons.favorite_border_rounded
                            : _busca.isEmpty
                            ? Icons.travel_explore_rounded
                            : Icons.search_off_rounded,
                        titulo: _somenteFavoritos
                            ? 'Nenhum favorito'
                            : _busca.isEmpty
                            ? 'Ainda não há lugares'
                            : 'Nenhum resultado',
                        mensagem: _somenteFavoritos
                            ? 'Toque no coração dos lugares para adicioná-los aqui.'
                            : _busca.isEmpty
                            ? 'Cadastre o primeiro destino e comece a montar seu guia.'
                            : 'Tente buscar por outro nome ou categoria.',
                        acao: !_somenteFavoritos && _busca.isEmpty
                            ? OutlinedButton.icon(
                                onPressed: _abrirCadastro,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Adicionar lugar'),
                              )
                            : null,
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: lugaresFiltrados.length,
                        itemBuilder: (context, index) => _buildLugarCard(
                          controller,
                          lugaresFiltrados[index],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
