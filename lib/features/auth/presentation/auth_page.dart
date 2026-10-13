import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'register_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  void toggleView() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return LoginScreen(onTapRegister: toggleView);
    } else {
      return RegisterScreen(onTapLogin: toggleView);
    }
  }
}
