// lib/screens/transaction/views/add_product_screen.dart (VERSI BARU)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_tracker/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'scan_barcode.dart';

enum FormMode { newProduct, addStock }

class AddProductScreen extends StatefulWidget {
  final String? initialBarcode;
  const AddProductScreen({this.initialBarcode, super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();

  FormMode _formMode = FormMode.newProduct;
  Map<String, dynamic>? _existingProduct;
  XFile? _selectedImage; // State untuk menyimpan file gambar

  @override
  void initState() {
    super.initState();
    _barcodeController.addListener(_checkBarcode);
    if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
    }
  }

  @override
  void dispose() {
    _barcodeController.removeListener(_checkBarcode);
    _barcodeController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Kompresi kualitas gambar (0-100)
      maxWidth: 1024, // Batasi lebar maksimal gambar
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _openBarcodeScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanBarcode()),
    );

    if (result != null) {
      _barcodeController.text = result;
    }
  }

  // Fungsi yang dijalankan setiap kali barcode berubah
  void _checkBarcode() {
    final barcode = _barcodeController.text;
    if (barcode.isEmpty) {
      _resetForm(FormMode.newProduct);
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final foundProduct = productProvider.findProductByBarcode(barcode);

    if (foundProduct != null) {
      // Jika produk ditemukan
      setState(() {
        _formMode = FormMode.addStock;
        _existingProduct = foundProduct;
        _nameController.text = foundProduct['name'];
        _categoryController.text = foundProduct['category'];
        _quantityController.clear();
      });
    } else {
      // Jika produk tidak ditemukan
      _resetForm(FormMode.newProduct);
    }
  }

  void _resetForm(FormMode mode) {
    setState(() {
      _formMode = mode;
      _existingProduct = null;
      _nameController.clear();
      _categoryController.clear();
      _quantityController.clear();
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final productProvider = context.read<ProductProvider>();
      final barcode = _barcodeController.text;
      final quantity = int.tryParse(_quantityController.text) ?? 0;

      if (_formMode == FormMode.newProduct) {
        productProvider.addNewProduct(
          id: barcode,
          name: _nameController.text,
          category: _categoryController.text,
          initialStock: quantity,
          imagePath: _selectedImage?.path, // Kirim path gambar
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk baru berhasil ditambahkan!')),
        );
      } else {
        productProvider.addStockToProduct(id: barcode, quantity: quantity);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok berhasil ditambahkan!')),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNewProduct = _formMode == FormMode.newProduct;
    final categoryOptions = context.read<ProductProvider>().categorySuggestions;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(isNewProduct ? 'Tambah Produk Baru' : 'Tambah Stok'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!isNewProduct)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Produk '${_existingProduct?['name']}' sudah ada.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontSize: 16,
                    ),
                  ),
                ),

              // Widget untuk memilih gambar
              if (isNewProduct) ...[
                _ImagePickerBox(
                  selectedImage: _selectedImage,
                  onTap: _pickImage,
                ),
                const SizedBox(height: 24),
              ],

              _InputForm(
                controller: _barcodeController,
                labelText: 'Barcode',
                prefixIcon: FontAwesomeIcons.barcode,
                suffixIcon: IconButton(
                  icon: const Icon(FontAwesomeIcons.camera, color: Colors.grey),
                  onPressed: _openBarcodeScanner,
                ),
                validator:
                    (v) =>
                        (v == null || v.isEmpty)
                            ? 'Barcode tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 16),

              _InputForm(
                controller: _nameController,
                labelText: 'Nama Barang',
                prefixIcon: FontAwesomeIcons.tag,
                enabled: isNewProduct,
                validator:
                    (v) =>
                        (isNewProduct && (v == null || v.isEmpty))
                            ? 'Nama tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 16),

              // Mengganti _InputForm biasa dengan Autocomplete
              Autocomplete<String>(
                // Controller yang sama digunakan untuk input dan menyimpan hasil
                initialValue: TextEditingValue(text: _categoryController.text),

                // 1. Membangun daftar pilihan/sugesti
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<
                      String
                    >.empty(); // Jangan tampilkan apa-apa jika kosong
                  }
                  return categoryOptions.where((String option) {
                    return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },

                // 2. Aksi saat sebuah sugesti dipilih
                onSelected: (String selection) {
                  _categoryController.text = selection;
                },

                // 3. Membangun tampilan input field itu sendiri
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  // Kita bisa gunakan _InputForm kita agar stylenya konsisten
                  return _InputForm(
                    controller: fieldController,
                    focusNode: fieldFocusNode, // Penting untuk dihubungkan
                    labelText: 'Kategori',
                    prefixIcon: FontAwesomeIcons.shapes,
                    enabled: isNewProduct,
                    onChanged: (value) {
                      // Update controller utama kita secara manual
                      _categoryController.text = value;
                    },
                    validator:
                        (v) =>
                            (isNewProduct && (v == null || v.isEmpty))
                                ? 'Kategori tidak boleh kosong'
                                : null,
                  );
                },

                // 4. (Opsional) Membangun tampilan daftar pilihan
                optionsViewBuilder: (
                  BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options,
                ) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: SizedBox(
                        height: 200.0,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(option),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _InputForm(
                controller: _quantityController,
                labelText:
                    isNewProduct ? 'Jumlah Stok Awal' : 'Jumlah Stok Tambahan',
                prefixIcon: FontAwesomeIcons.box,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Jumlah tidak boleh kosong';
                  if (int.tryParse(v) == null)
                    return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _save,
                  child: Text(
                    isNewProduct ? 'Simpan Produk Baru' : 'Tambah Stok',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget reusable untuk input form yang lebih cantik
class _InputForm extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final FocusNode? focusNode; // Tambahkan ini
  final ValueChanged<String>? onChanged; // Tambahkan ini

  const _InputForm({
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.validator,
    this.keyboardType,
    this.focusNode, // Tambahkan ini
    this.onChanged, // Tambahkan ini
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode, // Gunakan ini
      onChanged: onChanged, // Gunakan ini
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, size: 18, color: Colors.grey.shade600),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

// Widget reusable untuk kotak pemilih gambar
class _ImagePickerBox extends StatelessWidget {
  final XFile? selectedImage;
  final VoidCallback onTap;

  const _ImagePickerBox({this.selectedImage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          // Tampilkan gambar jika sudah dipilih
          image:
              selectedImage != null
                  ? DecorationImage(
                    image: FileImage(File(selectedImage!.path)),
                    fit: BoxFit.cover,
                  )
                  : null,
        ),
        // Tampilkan ikon jika belum ada gambar
        child:
            selectedImage == null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.image,
                        color: Colors.grey.shade500,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pilih Gambar',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
                : null,
      ),
    );
  }
}
