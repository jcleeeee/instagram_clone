import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/auth/auth_state.dart';
import 'package:instagram_clone/screens/main_screen.dart';
import 'package:instagram_clone/screens/signin_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthState>().authStatus;

    WidgetsBinding.instance.addPostFrameCallback((_) {
        // 메인 페이지로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => authStatus == AuthStatus.authenticated
                ? MainScreen()
                : SigninScreen(),
          ),
              (route) => route.isFirst,
        );
    });
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
