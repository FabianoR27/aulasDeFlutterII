import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/camera_controller.dart';
import 'package:guia_turismo/controllers/lugares_controller.dart';
import 'package:guia_turismo/models/categoria_model.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/services/lugares_service.dart';
import 'package:guia_turismo/services/nominatim_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class CadastrarLugarScreen extends StatefulWidget {
  const CadastrarLugarScreen({super.key});

  @override
  State<CadastrarLugarScreen> createState() => _CadastrarLugarScreenState();
}

class _CadastrarLugarScreenState extends State<CadastrarLugarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _descricaoController = TextEditingController();
  late Future<List<CategoriaModel>> _categoriasFuture;
  CategoriaModel? _categoriaSelecionada;
  bool _buscandoEndereco = false;

  @override
  void initState() {
    super.initState();
    // Carrega as categorias válidas para o cadastro diretamente da API.
    _categoriasFuture = LugaresService().buscarCategorias();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  // Consulta o Nominatim e preenche os campos de latitude e longitude.
  Future<void> _buscarCoordenadas() async {
    if (_enderecoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um endereço ou CEP para buscar.'),
        ),
      );
      return;
    }

    setState(() => _buscandoEndereco = true);
    try {
      final coordenadas = await NominatimService().buscarCoordenadas(
        _enderecoController.text,
      );
      if (!mounted) return;
      _preencherCoordenadas(coordenadas);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coordenadas localizadas com sucesso.')),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível localizar o endereço: '
            '${erro.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _buscandoEndereco = false);
    }
  }

  // Atualiza ambos os campos com as coordenadas retornadas pelo serviço.
  void _preencherCoordenadas(LatLng coordenadas) {
    _latitudeController.text = coordenadas.latitude.toStringAsFixed(6);
    _longitudeController.text = coordenadas.longitude.toStringAsFixed(6);
  }

  // Valida o formato e os limites geográficos de cada coordenada.
  String? _validarCoordenada(String? valor, String nome) {
    final coordenada = double.tryParse(
      (valor ?? '').trim().replaceAll(',', '.'),
    );
    if (coordenada == null || !coordenada.isFinite) {
      return 'Informe uma $nome válida.';
    }
    if (nome == 'latitude' && (coordenada < -90 || coordenada > 90)) {
      return 'A latitude deve ficar entre -90 e 90.';
    }
    if (nome == 'longitude' && (coordenada < -180 || coordenada > 180)) {
      return 'A longitude deve ficar entre -180 e 180.';
    }
    return null;
  }

  // Valida o formulário e envia o lugar com categoria e coordenadas.
  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // Junta os campos do formulário em um único objeto para o controller.
    final categoria = _categoriaSelecionada;
    if (categoria == null) return;

    final lugar = LugaresModel(
      id: 0,
      nome: _nomeController.text.trim(),
      categoria: categoria.nome,
      categoriaId: categoria.id,
      latitude: double.parse(
        _latitudeController.text.trim().replaceAll(',', '.'),
      ),
      longitude: double.parse(
        _longitudeController.text.trim().replaceAll(',', '.'),
      ),
      descricao: _descricaoController.text.trim(),
      foto: context.read<CameraController>().imagemSelecionada?.path,
    );
    final controller = context.read<LugaresController>();
    final resposta = await controller.cadastrarLugar(lugar);
    if (!mounted) return;

    if (controller.erro.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(resposta)));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);
    messenger.showSnackBar(SnackBar(content: Text(resposta)));
  }

  // Exibe as categorias válidas ou um erro com opção para tentar novamente.
  Widget _seletorCategoria() {
    return FutureBuilder<List<CategoriaModel>>(
      future: _categoriasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(
                color: Color(0xFF22D3EE),
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Não foi possível carregar as categorias: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFFFF9B9B)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _categoriasFuture = LugaresService().buscarCategorias();
                  });
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          );
        }

        final categorias = snapshot.data ?? [];
        return DropdownButtonFormField<CategoriaModel>(
          initialValue: _categoriaSelecionada,
          decoration: const InputDecoration(
            labelText: 'Categoria',
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: categorias
              .map(
                (categoria) => DropdownMenuItem<CategoriaModel>(
                  value: categoria,
                  child: Text(categoria.nome),
                ),
              )
              .toList(),
          onChanged: categorias.isEmpty
              ? null
              : (categoria) {
                  setState(() => _categoriaSelecionada = categoria);
                },
          validator: (categoria) =>
              categoria == null ? 'Selecione uma categoria.' : null,
        );
      },
    );
  }

  // Abre as opções de câmera e galeria para visualizar uma foto do lugar.
  void _abrirOpcoesDeFoto(CameraController controller) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111B24),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                controller.tirarFotoComCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Selecionar da galeria'),
              onTap: () {
                Navigator.pop(context);
                controller.selecionarImagemDaGaleria();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Monta a tela de cadastro com o estilo escuro e ciano do aplicativo.
  @override
  Widget build(BuildContext context) {
    final carregando = context.watch<LugaresController>().carregando;

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar lugar')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF111B24),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF253442)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add_location_alt_rounded,
                      color: Color(0xFF22D3EE),
                      size: 30,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Compartilhe um destino para ajudar outras pessoas '
                        'a descobrirem novos lugares.',
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Consumer<CameraController>(
                builder: (context, cameraController, _) {
                  final imagem = cameraController.imagemSelecionada;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 170,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111B24),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF253442)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imagem == null
                            ? const Center(
                                child: Icon(
                                  Icons.photo_outlined,
                                  color: Color(0xFF64748B),
                                  size: 42,
                                ),
                              )
                            : Image.file(
                                File(imagem.path),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _abrirOpcoesDeFoto(cameraController),
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: Text(
                            imagem == null ? 'Adicionar foto' : 'Trocar foto',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomeController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nome do lugar',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (valor) => (valor?.trim().isEmpty ?? true)
                    ? 'Informe o nome do lugar.'
                    : null,
              ),
              const SizedBox(height: 14),
              _seletorCategoria(),
              const SizedBox(height: 14),
              TextField(
                controller: _enderecoController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _buscarCoordenadas(),
                decoration: const InputDecoration(
                  labelText: 'Endereço ou CEP',
                  hintText: 'Ex.: Avenida Paulista, São Paulo',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _buscandoEndereco ? null : _buscarCoordenadas,
                  icon: _buscandoEndereco
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.map_outlined),
                  label: Text(
                    _buscandoEndereco
                        ? 'Buscando endereço...'
                        : 'Buscar coordenadas no mapa',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        prefixIcon: Icon(Icons.north_rounded),
                      ),
                      validator: (valor) =>
                          _validarCoordenada(valor, 'latitude'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        prefixIcon: Icon(Icons.east_rounded),
                      ),
                      validator: (valor) =>
                          _validarCoordenada(valor, 'longitude'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descricaoController,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'O que torna esse lugar especial?',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 54),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: carregando ? null : _salvar,
                  icon: carregando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF06232B),
                          ),
                        )
                      : const Icon(Icons.add_location_alt_rounded),
                  label: Text(carregando ? 'Salvando...' : 'Cadastrar lugar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF22D3EE),
                    foregroundColor: const Color(0xFF06232B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
