import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'home.dart';
import 'tela1.dart';
import 'Historico.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  databaseFactory = databaseFactoryFfi;
  runApp(MaterialApp(
      title: "navigator app",
      debugShowCheckedModeBanner: false,
      home: Home(),
      initialRoute: "/",
      routes: {
        "/home": (context) => Home(),
        Tela1.routeName: (context) => Tela1(),
        Historico.routeName: (context) => Historico(),
      }));
}
