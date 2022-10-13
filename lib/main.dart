import 'package:flutter/foundation.dart';

import 'widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCzJonEAgC4Ytet1HBTV2c8NNrhoLCxAVE",
        appId: "1:175502886994:web:1e011dc6959f6874ca378b",
        messagingSenderId: "175502886994",
        projectId: "final-project-bd88c",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WidgetTree(),
    );
  }
}
