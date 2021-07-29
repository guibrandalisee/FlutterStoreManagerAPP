import 'package:flutter/material.dart';
import 'package:onlinestoremanager/screens/loginScreen/loginScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          tooltipTheme: TooltipThemeData(
            textStyle: TextStyle(color: Colors.white),
            decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(5)),
          ),
          primarySwatch: Colors.pink,
          brightness: Brightness.dark,
          accentColor: Colors.pinkAccent),
      home: LoginScreen(),
    );
  }
}
