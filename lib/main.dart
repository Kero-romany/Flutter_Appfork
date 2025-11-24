import 'package:flutter/material.dart';
import 'package:sakkeny_app/pages/FilterPage.dart';
import 'package:sakkeny_app/pages/property.dart';
import 'package:sakkeny_app/pages/sign_in.dart';
import 'package:sakkeny_app/pages/MessagesPage.dart';
import 'package:sakkeny_app/pages/HomePage.dart';
import 'package:sakkeny_app/pages/Saved_List.dart';
import 'package:sakkeny_app/pages/sign_up.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
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
    return SignUpPage();
  }
}
