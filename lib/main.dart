import 'package:firebase_core/firebase_core.dart';
import 'package:inventory_tracker/app.dart';
import 'package:flutter/material.dart';
import 'package:inventory_tracker/firebase_options.dart';
import 'package:inventory_tracker/providers/auth_provider.dart';
import 'package:inventory_tracker/providers/product_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ubah menjadi async
  WidgetsFlutterBinding.ensureInitialized(); // Wajib ada
  await Firebase.initializeApp(
    // Inisialisasi Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
