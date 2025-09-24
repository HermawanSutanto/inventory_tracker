// lib/app.dart

import 'package:flutter/material.dart';
import 'package:inventory_tracker/app_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tidak perlu provider lagi di sini
    return const MyAppView();
  }
}
