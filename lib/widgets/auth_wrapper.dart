// lib/widgets/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:inventory_tracker/providers/auth_provider.dart';
import 'package:inventory_tracker/screens/auth/login_scren.dart';
import 'package:inventory_tracker/screens/home/views/home_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return const HomeScreen(); // Jika sudah login, tampilkan HomeScreen
    } else {
      return const LoginScreen(); // Jika belum, tampilkan LoginScreen
    }
  }
}
