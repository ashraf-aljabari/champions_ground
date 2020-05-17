import 'package:com/pages/login_page.dart';
import 'package:com/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.blueAccent,
      systemNavigationBarIconBrightness: Brightness.dark,

    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Champions Ground',
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        accentColor: Colors.grey,

      ),
      home: LoginPage(),
    );
  }
}



