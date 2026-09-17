// importando o sqflite
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aula_2608/models/contato_model.dart';

class ContatoBanco {
  Future<Database> iniciarBanco() async {
    return await openDatabase(
      // caminho do banco de dados
      join(await getDatabasesPath(), 'contatos.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE contatos(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, telefone TEXT, email TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<List<ContatoModel>> listarContatos() async {
    final db = await iniciarBanco();
    final List<Map<String, dynamic>> json = await db.query('contatos');

    return json.map((item) => ContatoModel.fromJson(item)).toList();
  }

  Future<bool> inserirContato(ContatoModel dadosContato) async {
    final db = await iniciarBanco();
    await db.insert('contatos', dadosContato.toJson());
    return true;
  }

  Future<bool> atualizarContato(ContatoModel dadosContato) async {
    final db = await iniciarBanco();
    await db.update(
      'contatos',
      dadosContato.toJson(),
      where: 'id = ?',
      whereArgs: [dadosContato.id],
      conflictAlgorithm: ConflictAlgorithm.replace
    );
    return true;
  }

  Future<bool> deletarContato(int id) async {
    final db = await iniciarBanco();
    await db.delete(
      'contatos',
      where: 'id = ?',
      whereArgs: [id],
    );
    return true;
  }
}
