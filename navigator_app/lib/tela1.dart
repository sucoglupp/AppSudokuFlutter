import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sudoku_dart/sudoku_dart.dart';
import 'arguments.dart';
import 'Historico.dart';
import 'package:flutter/services.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';
import 'home.dart';

class Tela1 extends StatefulWidget {
  String name = "";

  static String routeName = "/tela1";

  Tela1() {}

  Tela1.name(this.name);

  @override
  State<Tela1> createState() => _Tela1State();
}

class _Tela1State extends State<Tela1> {
  var rng = Random();
  late int rd = rng.nextInt(4);
  List<List<int>> _puzzle = [];
  List<List<int>> _solution = [];
  int _selectedRow = -1;
  int _selectedCol = -1;
  bool _isComplete = false;
  SudokuGenerator generator = SudokuGenerator(emptySquares: 54);
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  SudokuGenerator puzzlediff(int diff) {
    switch (diff) {
      case 1:
        SudokuGenerator generator = SudokuGenerator(emptySquares: 18);
        return generator;
      case 2:
        SudokuGenerator generator = SudokuGenerator(emptySquares: 27);
        return generator;
      case 3:
        SudokuGenerator generator = SudokuGenerator(emptySquares: 36);
        return generator;
      case 4:
        SudokuGenerator generator = SudokuGenerator(emptySquares: 54);
        return generator;
    }
    return generator;
  }

  void _generatePuzzle() {
    _solution = generator.newSudokuSolved;
    _puzzle = generator.newSudoku;
  }

  void _checkComplete(String name, level) {
    // Check if the puzzle is complete
    _isComplete = true;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (_puzzle[i][j] == 0) {
          _isComplete = false;
          return;
        }
        if (_puzzle[i][j] != _solution[i][j]) {
          _isComplete = false;
        }
      }
    }
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    Historico.createItem(name, 1, formattedDate, level);
  }

  void _selectCell(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  Widget _buildNumberButton(int number, String name, int level) {
    return ElevatedButton(
      child: Text(number.toString()),
      onPressed: () {
        _enterNumber(number, name, level);
      },
    );
  }

  void _enterNumber(int number, String name, int level) {
    if (_selectedRow != -1 && _selectedCol != -1) {
      setState(() {
        _puzzle[_selectedRow][_selectedCol] = number;
        _checkComplete(name, level);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as Arguments;

    return Scaffold(
        appBar: AppBar(
          title: Text("Sudoku"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                args.name,
                style: TextStyle(fontSize: 20),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 9,
                  children: List.generate(81, (index) {
                    int row = index ~/ 9;
                    int col = index % 9;
                    return GestureDetector(
                      onTap: () {
                        _selectCell(row, col);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: _selectedRow == row && _selectedCol == col
                              ? Colors.yellow
                              : Colors.white,
                        ),
                        child: Text(
                          _puzzle[row][col] == 0
                              ? ''
                              : _puzzle[row][col].toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _puzzle[row][col] == _solution[row][col]
                                ? Colors.green
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 16),
              _isComplete
                  ? Text(
                      'Congratulations! You solved the puzzle!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  : SizedBox(),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildNumberButton(1, args.name, rd),
                  _buildNumberButton(2, args.name, rd),
                  _buildNumberButton(3, args.name, rd),
                  _buildNumberButton(4, args.name, rd),
                  _buildNumberButton(5, args.name, rd),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildNumberButton(6, args.name, rd),
                  _buildNumberButton(7, args.name, rd),
                  _buildNumberButton(8, args.name, rd),
                  _buildNumberButton(9, args.name, rd),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _generatePuzzle();
                        _selectedRow = -1;
                        _selectedCol = -1;
                        _isComplete = false;
                      });
                      DateTime now = DateTime.now();
                      String formattedDate =
                          DateFormat('yyyy-MM-dd – kk:mm').format(now);
                      Historico.createItem(args.name, 0, formattedDate, rd);
                      Navigator.pop(context);
                    },
                    child: Text("New Game")),
              )
            ],
          ),
        ));
  }
}
