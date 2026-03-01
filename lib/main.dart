import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PhotoGuideApp());
}

class PhotoGuideApp extends StatelessWidget {
  const PhotoGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Retouch Your Photo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}