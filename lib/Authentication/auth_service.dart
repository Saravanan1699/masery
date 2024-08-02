import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home-pages/cartpage.dart';
import 'Sing-in.dart';

class AuthService {
  static Future<void> _setLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
  }

  static Future<void> logout(BuildContext context) async {
    await _setLoginStatus(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Signin()),
    );
  }

  static Future<void> login(BuildContext context, String username, String password) async {
    bool loginSuccess = true;

    if (loginSuccess) {
      await _setLoginStatus(true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CartPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
  }

  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
