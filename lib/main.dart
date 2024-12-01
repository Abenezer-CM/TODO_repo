import 'package:flutter/material.dart';
import 'package:todoapp/screens/todo_screen.dart';
import 'package:flutter/services.dart';

void main() {
  // Ensure the Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const TodoScreen(),
    );
  }
}
