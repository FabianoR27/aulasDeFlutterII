import 'package:loja_doces/models/doces_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ProdutosBanco {
  Future<Database> iniciarBanco() async {
    return openDatabase(
      join(await getDatabasesPath(), 'doces.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            descricao TEXT,
            categoria TEXT,
            valor REAL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<List<ProdutoModel>> listarProdutos() async {
    final db = await iniciarBanco();
    final List<Map<String, dynamic>> json = await db.query('produtos');
    return json.map((item) => ProdutoModel.fromJson(item)).toList();
  }

  Future<bool> inserirProduto(ProdutoModel produto) async {
    final db = await iniciarBanco();
    await db.insert('produtos', produto.toJson());
    return true;
  }

  Future<bool> atualizarProduto(ProdutoModel produto) async {
    final db = await iniciarBanco();
    await db.update(
      'produtos',
      produto.toJson(),
      where: 'id = ?',
      whereArgs: [produto.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  Future<bool> deletarProduto(int id) async {
    final db = await iniciarBanco();
    await db.delete(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );
    return true;
  }
}