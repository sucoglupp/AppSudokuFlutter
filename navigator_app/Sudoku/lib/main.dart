import 'package:flutter/material.dart';
import 'home.dart';
import 'tela1.dart';

void main(){
  runApp(
    MaterialApp(
      title: "navigator app",
      debugShowCheckedModeBanner: false,
      home: Home(),
      initialRoute: "/",
      routes: {
        "/home": (context) => Home(),
        Tela1.routeName: (context) => Tela1(),

      }
    )
  );
}