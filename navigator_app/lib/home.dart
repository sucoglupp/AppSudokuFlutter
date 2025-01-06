import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navigator_app/Historico.dart';
import 'Historico.dart';
import 'arguments.dart';
import 'tela1.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int? diff = -1;
  TextEditingController textController = TextEditingController();
  bool radioOn = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: "Digite o seu nome:"),
                  controller: textController),
              Text(
                "Select Dificulty",
                style: TextStyle(fontSize: 18),
              ),
              Divider(),
              RadioListTile(
                title: Text("easy"),
                value: 1,
                groupValue: diff,
                onChanged: (int? val) {
                  setState(() {
                    if (radioOn == true) {
                      diff = val;
                    }
                  });
                },
              ),
              RadioListTile(
                title: Text("medium"),
                value: 2,
                groupValue: diff,
                onChanged: (int? val) {
                  setState(() {
                    if (radioOn == true) {
                      diff = val;
                    }
                  });
                },
              ),
              RadioListTile(
                title: Text("hard"),
                value: 3,
                groupValue: diff,
                onChanged: (int? val) {
                  setState(() {
                    if (radioOn == true) {
                      diff = val;
                    }
                  });
                },
              ),
              RadioListTile(
                title: Text("expert"),
                value: 4,
                groupValue: diff,
                onChanged: (int? val) {
                  setState(() {
                    if (radioOn == true) {
                      diff = val;
                    }
                  });
                },
              ),
              ElevatedButton(
                  onPressed: () {
                    print("TextField: ${textController.text}");

                    Navigator.pushNamed(context, Tela1.routeName,
                        arguments: Arguments(textController.text));
                  },
                  child: Text("Iniciar Novo Jogo")),
              ElevatedButton(
                  onPressed: () {
                    print("TextField: ${textController.text}");

                    Navigator.pushNamed(context, Historico.routeName,
                        arguments: Arguments(textController.text));
                  },
                  child: Text("Ver Historico de Partidas"))
            ],
          ),
        ));
  }
}
