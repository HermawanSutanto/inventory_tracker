import 'package:firebase_core/firebase_core.dart';
import 'package:inventory_tracker/app.dart';
import 'package:flutter/material.dart';
import 'package:inventory_tracker/firebase_options.dart';
import 'package:inventory_tracker/providers/auth_provider.dart';
import 'package:inventory_tracker/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Ubah menjadi async
  WidgetsFlutterBinding.ensureInitialized(); // Wajib ada
  await Firebase.initializeApp(
    // Inisialisasi Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://cygltuwskmyfqmdeeqmi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5Z2x0dXdza215ZnFtZGVlcW1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2MDkwNjQsImV4cCI6MjA3NDE4NTA2NH0.-xLiy-PYNedb1GXOBr83lgtiBqk9PVHYZ-AwvUKqkhU',
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
