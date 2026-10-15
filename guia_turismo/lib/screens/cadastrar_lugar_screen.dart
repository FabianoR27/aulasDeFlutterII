import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:guia_turismo/controllers/lugares_controller.dart';
// import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/controllers/camera_controller.dart';

class CadastrarLugarScreen extends StatefulWidget {
  const CadastrarLugarScreen({super.key});

  @override
  State<CadastrarLugarScreen> createState() => _CadastrarLugarScreenState();
}

// ======================================================
// IGNORE O CÓDIGO COMENTADO ABAIXO, POIS EU ESTAVA TENDO UMA IDEIA MIRABOLANTE QUE NÃO DEU CERTO AINDA, MAS VOU TENTAR USAR DEPOIS :)
// ======================================================

class _CadastrarLugarScreenState extends State<CadastrarLugarScreen> {
  /*
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _descricaoController = TextEditingController();
*/

  @override
  /* void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }
*/
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar lugar')),
      body: Consumer<CameraController>(
        builder: (context, cameraController, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                // alinhar a imagem e o botão de câmera no centro da tela
                Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111B24),
                      border: Border.all(width: 2),
                      borderRadius: BorderRadius.circular(16),
                      image: exibirImagem(cameraController),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => abrirModal(cameraController, context),
                    icon: const Icon(Icons.camera_alt_rounded),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DecorationImage exibirImagem(CameraController controle) {
    if (controle.imagemSelecionada == null) {
      return DecorationImage(
        image: NetworkImage('https://placehold.jp/150x150.png'),
        fit: BoxFit.cover,
      );
    } else {
      return DecorationImage(
        image: FileImage(controle.imagemSelecionada!),
        fit: BoxFit.cover,
      );
    }
  }

  void abrirModal(CameraController controle, context) {
    showModalBottomSheet(
      context:context,
      builder: (context) =>
      SafeArea(bottom: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          ListTile(
            leading: Icon(Icons.camera),
            onTap: () {
              controle.tirarFotoComCamera();
              Navigator.pop(context);
            },
            title: Text('Tirar foto'),
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            onTap: () {
              controle.selecionarImagemDaGaleria();
              Navigator.pop(context);
            },
            title: Text('Selecionar da galeria'),
          ),
        ],
        ),
      ),
    );
  }


// ======================================================
// IGNORE O CÓDIGO COMENTADO ABAIXO, POIS EU ESTAVA TENDO UMA IDEIA MIRABOLANTE QUE NÃO DEU CERTO AINDA, MAS VOU TENTAR USAR DEPOIS :)
// ======================================================


  /*
  String? _validarCoordenada(String? value, String nome) {
    final coordenada = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (coordenada == null) return 'Informe uma $nome válida.';
    if (nome == 'latitude' && (coordenada < -90 || coordenada > 90)) {
      return 'A latitude deve ficar entre -90 e 90.';
    }
    if (nome == 'longitude' && (coordenada < -180 || coordenada > 180)) {
      return 'A longitude deve ficar entre -180 e 180.';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final lugar = LugaresModel(
      id: 0,
      nome: _nomeController.text.trim(),
      categoria: _categoriaController.text.trim(),
      latitude: double.parse(_latitudeController.text.trim().replaceAll(',', '.')),
      longitude:
          double.parse(_longitudeController.text.trim().replaceAll(',', '.')),
      descricao: _descricaoController.text.trim(),
    );
    final resposta = await context.read<LugaresController>().cadastrarLugar(lugar);
    if (!mounted) return;

    if (resposta.startsWith('Erro') || resposta.contains('não fornecido')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resposta)),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);
    messenger.showSnackBar(SnackBar(content: Text(resposta)));
  }

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
                    Icon(Icons.add_location_alt_rounded,
                        color: Color(0xFF22D3EE), size: 30),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Compartilhe um destino para ajudar outras pessoas a descobrirem novos lugares.',
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nome do lugar',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Informe o nome do lugar.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _categoriaController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  hintText: 'Ex.: Praia, parque, museu',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Informe uma categoria.'
                    : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true, signed: true),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        prefixIcon: Icon(Icons.north_rounded),
                      ),
                      validator: (value) => _validarCoordenada(value, 'latitude'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true, signed: true),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        prefixIcon: Icon(Icons.east_rounded),
                      ),
                      validator: (value) => _validarCoordenada(value, 'longitude'),
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
              const SizedBox(height: 28),
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
  }*/
}
