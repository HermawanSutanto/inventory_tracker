import 'package:flutter/material.dart';
import 'package:inventory_tracker/widgets/auth_wrapper.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ExpenseTracker",
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.red,
          background: Colors.grey.shade100,
          onBackground: Colors.black,
          surface: Colors.grey.shade100,
          onSurface: Colors.black,
          primary: Color.fromARGB(255, 255, 139, 30),
          secondary: Color.fromARGB(255, 241, 129, 129),
          tertiary: Color.fromARGB(255, 255, 227, 69),
          outline: Colors.grey,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
