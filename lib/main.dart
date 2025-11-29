import 'package:flutter/material.dart';
import 'package:sakkeny_app/pages/HomePage.dart';
import 'package:sakkeny_app/pages/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saknni App', home:  SplashScreen());
  }
}
