import 'package:flutter/material.dart';
import 'package:go_to_venezia2/date_extension.dart';
import 'package:provider/provider.dart';

import 'pages/homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'GoTo Venezia',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: HomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  DateTime date = DateTime.now().getDate();
  void setDate(DateTime d) {
    date = d.getDate();
    notifyListeners();
  }
}