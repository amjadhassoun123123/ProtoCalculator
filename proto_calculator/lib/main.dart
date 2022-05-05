import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();
  bool reset = false;
  List<String> icon = [
    "7",
    "8",
    "9",
    "*",
    "4",
    "5",
    "6",
    "/",
    "1",
    "2",
    "3",
    "-",
    "CLEAR",
    "0",
    "=",
    "+"
  ];

  void addText(String text) {
    List<String> list = ["+", "-", "/", "*"];
    if (text == "=") {
      try {
        myController.text = myController.text.interpret().toString();
        reset = true;
      } catch (e) {
        myController.text = "";
      }
      return;
    } else if (text == "CLEAR") {
      myController.text = "";
      return;
    } else if (!reset) {
      myController.text = myController.value.text + text;
      return;
    } else if (list.contains(text)) {
      myController.text = myController.value.text + text;
      reset = false;
      return;
    }
    myController.text = text;
    reset = false;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Column(
        children: [
          TextField(
            textAlign: TextAlign.right,
            style:
                const TextStyle(fontSize: 50, color: Colors.deepPurpleAccent),
            decoration: const InputDecoration(
              labelText: 'OoooooOOooooOO math stuff',
            ),
            controller: myController,
            readOnly: true,
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 3,
              children: 
                icon.map( (i) { return
                   TextButton(
                    onPressed: () {
                      addText(i);
                    },
                    child: Text(
                      i,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ); }).toList(),
            ),
          ) 
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
