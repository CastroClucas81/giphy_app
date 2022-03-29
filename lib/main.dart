import 'package:flutter/material.dart';
import 'package:giphy_app/ui/home_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        hintColor: Colors.white,
      ),
      home: HomePage(),
    ),
  );
}
