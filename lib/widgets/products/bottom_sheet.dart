import 'package:flutter/material.dart';

class BottomSheetExample extends StatelessWidget {
  final String productName;
  final String id;
  final String category;
  final int stock;
  final int capacity;
  const BottomSheetExample({
    super.key,
    required this.productName,
    required this.category,
    required this.id,
    required this.stock,
    required this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contoh Bottom Sheet'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Tampilkan Bottom Sheet'),
          onPressed: () {
            _showSimpleBottomSheet(context);
          },
        ),
      ),
    );
  }

  void _showSimpleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Untuk keyboard yang muncul
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Formulir Sederhana',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Kirim'),
                onPressed: () {
                  Navigator.pop(context); // Menutup bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
