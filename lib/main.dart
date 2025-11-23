import 'package:flutter/material.dart';
import 'screens/homePage.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const HomePage(),
      '/login': (context) => const HomePage(),
      '/signup': (context) => const HomePage(),
      '/create-post': (context) => const HomePage(),
      '/favorites': (context) => const HomePage(),
      '/notifications': (context) => const HomePage(),
      '/profile': (context) => const HomePage(),
      '/viewItem': (context) => const HomePage(),
      '/all-messages': (context) => const HomePage(),


    },
  ));
}