import 'package:flutter/material.dart';
import 'package:csc322upgrades2/task_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const TaskPage(),
    );
  }
}