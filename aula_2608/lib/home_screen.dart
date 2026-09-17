import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // =====================================
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  void abrirFormulario(contato) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cadastro de Contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomeController..text = contato['nome'],
                decoration: InputDecoration(
                  labelText: 'Nome',
                ),
              ),
              SizedBox(height: 16.0),

              TextField(
                controller: _telefoneController..text = contato['Telefone'],
                decoration: InputDecoration(
                  labelText: 'Telefone',
                ),
              ),
              SizedBox(height: 16.0),

              TextField(
                controller: _emailController..text = contato['email'],
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Salvar')),
          ],
        );
      },
    );
  }

  //====================================

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de contatos!")),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(""),
              subtitle: Text(""),
              trailing: IconButton(
                onPressed: () {},
                icon: Icon(CupertinoIcons.pencil),
              ),
              leading: CircleAvatar(
                backgroundColor: const Color.fromARGB(225, 0, 0, 0),
                child: Icon(CupertinoIcons.person, color: Colors.white),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          abrirFormulario(null);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}