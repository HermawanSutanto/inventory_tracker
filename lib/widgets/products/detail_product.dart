import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailProduct extends StatelessWidget {
  const DetailProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Product Title',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const _ItemImage(),
              const SizedBox(height: 20),

              _InputForm(
                hintText: 'Barcode',
                prefixIcon: FontAwesomeIcons.barcode,
                suffixIcon: IconButton(
                  icon: const Icon(FontAwesomeIcons.camera, color: Colors.grey),
                  onPressed: () {
                    // Handle barcode scanner button press
                  },
                ),
              ),
              const SizedBox(height: 10),

              _InputForm(
                hintText: 'masukkan nama barang',
                prefixIcon: CupertinoIcons.add,
              ),
              const SizedBox(height: 10),

              _InputForm(
                hintText: 'masukkan kategori barang',
                prefixIcon: FontAwesomeIcons.shapes,
              ),
              const SizedBox(height: 10),

              _InputForm(
                hintText: 'masukkan jumlah barang',
                prefixIcon: FontAwesomeIcons.ruler,
              ),
              SizedBox(height: 10),
              // _SaveButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const Icon(FontAwesomeIcons.camera, color: Colors.grey, size: 40),
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Text(
            'Gambar Barang',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}

class _InputForm extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const _InputForm({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(prefixIcon, size: 16, color: Colors.grey),
        suffixIcon: suffixIcon, // Menambahkan suffixIcon di sini
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
      ),
    );
  }
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
