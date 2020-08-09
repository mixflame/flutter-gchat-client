import 'package:flutter/material.dart';

import './pages/homepage.dart';

final homekey = new GlobalKey<HomePageState>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(key: homekey),
    );
  }
}
