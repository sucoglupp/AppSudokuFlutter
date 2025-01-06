import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'dart:async';
import 'main.dart';
import 'tela1.dart';

class Historico extends StatefulWidget {
  String name = "";
  static Future<int> createItem(
      String? name, int result, String? date, int level) async {
    final db = await _HistoricoState.db();

    final data = {
      "name": name,
      "result": result,
      "date": date,
      "level": level,
    };
    final id = await db.insert('sudoku', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print("Novo registro: $id");
    return id;
  }

  static String routeName = "/Historico";

  Historico() {}

  Historico.name(this.name);
  @override
  State<Historico> createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  Map<int, int> qtdPartidas = {};
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'flutterjunction.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  List<String> listaFiltrada = [];
  String filtro = "";

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE sudoku(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    result INTEGER,
    date VARCHAR NOT NULL,
    level INTEGER
      )
      """);
  }

  static Future<int> createItem(
      String? name, int result, String? date, int level) async {
    final db = await _HistoricoState.db();

    final data = {
      "name": name,
      "result": result,
      "date": date,
      "level": level,
    };
    final id = await db.insert('sudoku', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print("Novo registro: $id");
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await _HistoricoState.db();
    return db.query('sudoku', orderBy: "id");
  }

  Future<void> _QtdPartidas() async {
    final db = await _HistoricoState.db();
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT level, COUNT(*) AS quantidade
      FROM sudoku
      GROUP BY level
''');
    setState(() {
      qtdPartidas = {
        for (var i in res) i['level'] as int: i['quantidade'] as int
      };
    });
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await _HistoricoState.db();
    return db.query('sudoku', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<void> _deleteItem(int id) async {
    final db = await _HistoricoState.db();
    try {
      await db.delete("sudoku", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<int> _updateItem(
      int id, String name, int result, String? data, int level) async {
    final db = await _HistoricoState.db();

    final data = {
      "name": name,
      "result": 0,
      "date": "10/10/2003",
      "level": level
    };

    final result =
        await db.update('sudoku', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  List<Map<String, dynamic>> myData = [];
  final formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshData() async {
    final data = await _HistoricoState.getItems();
    setState(() {
      myData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
    _QtdPartidas();
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  void showMyForm(int? id) async {
    if (id != null) {
      final existingData = myData.firstWhere((element) => element['id'] == id);
      _nameController.text = existingData['name'];
      _resultController.text = existingData['result'];
      _dataController.text = existingData['data'];
      _levelController.text = existingData['level'];
    } else {
      _nameController.text = "";
      _resultController.text = "";
      _dataController.text = "";
      _levelController.text = "";
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isDismissible: false,
        isScrollControlled: true,
        builder: (_) => Container(
            padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: formValidator,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _resultController,
                    validator: formValidator,
                    decoration: const InputDecoration(hintText: 'result'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    validator: formValidator,
                    controller: _dataController,
                    decoration: const InputDecoration(hintText: 'Data'),
                  ),
                  TextFormField(
                    controller: _levelController,
                    validator: formValidator,
                    decoration: const InputDecoration(hintText: 'level'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Exit")),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (id == null) {
                              await addItem();
                            }

                            if (id != null) {
                              await updateItem(id);
                            }

                            setState(() {
                              _nameController.text = '';
                              _resultController.text = '';
                              _dataController.text = '';
                              _levelController.text = '';
                            });

                            Navigator.pop(context);
                          }
                          // Save new data
                        },
                        child: Text(id == null ? 'Create New' : 'Update'),
                      ),
                    ],
                  )
                ],
              ),
            )));
  }

  String? formValidator(String? value) {
    if (value!.isEmpty) return 'Field is Required';
    return null;
  }

  Future<void> addItem() async {
    int leveln = int.parse(_levelController.text);
    int resultn = int.parse(_resultController.text);

    await _HistoricoState.createItem(
        _nameController.text, resultn, _dataController.text, leveln);
    _refreshData();
  }

  // Update an existing data
  Future<void> updateItem(int id) async {
    await _HistoricoState._updateItem(
        id, _nameController.text, 1, _dataController.text, 3);
    _refreshData();
  }

  // Delete an item
  void deleteItem(int id) async {
    await _HistoricoState._deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully deleted!'), backgroundColor: Colors.green));
    _refreshData();
  }

  void searchbydiff() {
    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
              child: qtdPartidas.isEmpty
                  ? Center(child: Text("No Data Available :("))
                  : ListView.builder(
                      itemCount: qtdPartidas.length,
                      itemBuilder: (context, index) {
                        int nivel = qtdPartidas.keys.elementAt(index);
                        int qtd = qtdPartidas.values.elementAt(index);
                        String txtNivel;
                        if (nivel == 0) {
                          txtNivel = "Easy";
                        } else if (nivel == 1) {
                          txtNivel = "Medium";
                        } else if (nivel == 2) {
                          txtNivel = "Hard";
                        } else {
                          txtNivel = "Expert";
                        }
                        return ListTile(
                          title: Text(
                            "Nível de Jogo: $txtNivel",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Partidas jogadas: $qtd",
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      }),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historico de Partidas'),
        /*leading: IconButton(
            onPressed: () => searchbydiff(),
            icon: Icon(Icons.search),
          )*/
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : myData.isEmpty
              ? const Center(child: Text("No Data Available!!!"))
              : ListView.builder(
                  itemCount: myData.length,
                  itemBuilder: (context, index) {
                    int level = myData[index]['level'];
                    String txtlevel;
                    if (level == 0) {
                      txtlevel = "Easy";
                    } else if (level == 1) {
                      txtlevel = "Medium";
                    } else if (level == 2) {
                      txtlevel = "Hard";
                    } else {
                      txtlevel = "Expert";
                    }
                    int result = myData[index]['result'];
                    String txtresult;
                    if (result == 0) {
                      txtresult = "defeat";
                    } else {
                      txtresult = "victory";
                    }
                    return Card(
                      color: index % 2 == 0 ? Colors.green : Colors.green[200],
                      margin: const EdgeInsets.all(15),
                      child: ListTile(
                          title: Text(myData[index]['name']),
                          subtitle: Text(txtresult +
                              " " +
                              myData[index]['date'] +
                              " " +
                              txtlevel),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      showMyForm(myData[index]['id']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      deleteItem(myData[index]['id']),
                                ),
                              ],
                            ),
                          )),
                    );
                  }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () => searchbydiff(),
      ),
    );
  }
}
