import 'package:flutter/material.dart';
import 'package:parent_control/route.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Safe',
      initialRoute: '/splash',
      routes: appRoutes,
    );
  }
}
