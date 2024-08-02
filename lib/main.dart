import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Authentication/startscreen.dart';
import 'Home-pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenHandler(),
    );
  }
}

class SplashScreenHandler extends StatefulWidget {
  @override
  _SplashScreenHandlerState createState() => _SplashScreenHandlerState();
}

class _SplashScreenHandlerState extends State<SplashScreenHandler> {
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime');

    if (isFirstTime == null || isFirstTime) {
      // If first time, set isFirstTime to false for next app open
      await prefs.setBool('isFirstTime', false);
      setState(() {
        _isFirstTime = true;
      });
    } else {
      setState(() {
        _isFirstTime = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstTime) {
      return WelcomeSplashScreen();
    } else {
      return HomePage();
    }
  }
}
