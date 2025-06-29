import 'package:flutter/material.dart';
import 'views/converter_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system, // Автоматически тёмная/светлая тема
      debugShowCheckedModeBanner: false,
      home: const ConverterScreen(),
    );
  }
}
