import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await context.read<AuthProvider>().signOut();
          },
          child: Text('로그아웃'),
        ),
      ),
    );
  }
}
