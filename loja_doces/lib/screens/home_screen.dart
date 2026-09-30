import 'package:loja_doces/models/doces_model.dart';
import 'package:loja_doces/services/doces_banco.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _valorController = TextEditingController();
  List<ProdutoModel> _listarProdutos = [];

  @override
  void initState() {
    super.initState();
    _carregarLista();
  }

  Future<void> _carregarLista() async {
    final produtos = await ProdutosBanco().listarProdutos();
    if (!mounted) return;
    setState(() {
      _listarProdutos = produtos;
    });
  }

  void abrirFormulario(ProdutoModel produto) {
    _nomeController.text = produto.nome;
    _descricaoController.text = produto.descricao;
    _categoriaController.text = produto.categoria;
    _valorController.text = produto.valor == 0 ? '' : produto.valor.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(produto.id == null ? 'Novo doce' : 'Editar doce'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => _salvarDados(produto),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _salvarDados(ProdutoModel produto) async {
    final valor = double.tryParse(_valorController.text.trim().replaceAll(',', '.'));
    if (valor == null) return;

    final novoProduto = ProdutoModel(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      categoria: _categoriaController.text.trim(),
      valor: valor,
      id: produto.id,
    );

    final bool modoEdicao = produto.id != null;
    final bool cadastrou = modoEdicao
        ? await ProdutosBanco().atualizarProduto(novoProduto)
        : await ProdutosBanco().inserirProduto(novoProduto);

    if (cadastrou) {
      await _carregarLista();
      _nomeController.clear();
      _descricaoController.clear();
      _categoriaController.clear();
      _valorController.clear();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  void _abrirModalExclusao(ProdutoModel produto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir doce'),
          content: Text('Deseja realmente excluir o doce ${produto.nome}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                deletarProduto(produto.id!);
                Navigator.pop(context);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deletarProduto(int id) async {
    final bool deletou = await ProdutosBanco().deletarProduto(id);
    if (deletou) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doce excluído com sucesso!')),
      );
      await _carregarLista();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja de doces'),
        backgroundColor: Colors.pink,
      ),
      body: ListView.builder(
        itemCount: _listarProdutos.length,
        itemBuilder: (context, index) {
          final item = _listarProdutos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(item.nome),
              subtitle: Text(
                '${item.descricao} | ${item.categoria}\n'
                'R\$ ${item.valor.toStringAsFixed(2).replaceAll('.', ',')}',
              ),
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
              leading: CircleAvatar(
                backgroundColor: Colors.pink.shade100,
                child: const Icon(Icons.cake, color: Colors.pink),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          abrirFormulario(
            ProdutoModel(nome: '', descricao: '', categoria: '', valor: 0),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
