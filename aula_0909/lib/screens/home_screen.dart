import 'package:aula_0909/models/contato_model.dart';
import 'package:aula_0909/services/contato_banco.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  List<ContatoModel> _listarContatos = [];

  @override
  void initState() {
    super.initState();
    _carregarLista();
  }

  Future<void> _carregarLista() async {
    final contatos = await ContatoBanco().listarContatos();
    if (!mounted) return;
    setState(() {
      _listarContatos = contatos;
    });
  }

  void abrirFormulario(ContatoModel contato) {
    _nomeController.text = contato.nome;
    _emailController.text = contato.email;
    _telefoneController.text = contato.telefone;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cadastro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => _salvarDados(contato),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _salvarDados(ContatoModel contato) async {
    final novoContato = ContatoModel(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      telefone: _telefoneController.text.trim(),
      id: contato.id,
    );

    final bool modoEdicao = contato.id != null;
    final bool cadastrou = modoEdicao
        ? await ContatoBanco().atualizarContato(novoContato)
        : await ContatoBanco().inserirContato(novoContato);

    if (cadastrou) {
      await _carregarLista();
      _nomeController.clear();
      _emailController.clear();
      _telefoneController.clear();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  void _abrirModalExclusao(ContatoModel contato) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir contato'),
          content: Text('Deseja realmente excluir o contato ${contato.nome}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                deletarContato(contato.id!);
                Navigator.pop(context);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deletarContato(int id) async {
    final bool deletou = await ContatoBanco().deletarContato(id);
    if (deletou) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contato deletado com sucesso!')),
      );
      await _carregarLista();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de contatos'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: _listarContatos.length,
        itemBuilder: (context, index) {
          final item = _listarContatos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(item.nome),
              subtitle: Text('${item.email} - ${item.telefone}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => abrirFormulario(item),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => _abrirModalExclusao(item),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          abrirFormulario(ContatoModel(nome: '', email: '', telefone: ''));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
