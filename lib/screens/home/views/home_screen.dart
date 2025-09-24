import 'dart:math';

import 'package:inventory_tracker/screens/transaction/views/add_product.dart';
import 'package:inventory_tracker/screens/transaction/views/scan_barcode.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventory_tracker/screens/home/views/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_tracker/screens/products/views/product_list.dart';
import 'package:inventory_tracker/widgets/products/bottom_sheet/simple_bottom_sheet.dart';

// Asumsi: Anda memiliki file 'data.dart' dengan list allProducts
import 'package:inventory_tracker/data/data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var WidgetList = [MainScreen(), ProductList()];
  int index = 0;
  late Color selectedItem = Theme.of(context).colorScheme.primary;
  Color unselectedItem = Colors.grey;

  // Fungsi pembantu untuk mencari produk berdasarkan ID
  Map<String, dynamic>? _findProductById(String id) {
    try {
      return allProducts.firstWhere((product) => product['id'] == id);
    } catch (e) {
      return null;
    }
  }

  void _navigateToScanBarcodeThenShowDetail() async {
    final barcodeResult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanBarcode()),
    );

    if (barcodeResult != null) {
      final productData = _findProductById(barcodeResult);
      if (productData != null) {
        // Jika produk ditemukan, tampilkan bottom sheet
        showSimpleBottomSheet(
          context,
          initialStock: true,
          productName: productData['name']!,
          category: productData['category']!,
          id: productData['id']!,
          stock: productData['stock']!,
          capacity: productData['capacity']!,
          imageUrl: productData['imageUrl'],
        );
      } else {
        // Jika produk tidak ditemukan, tampilkan dialog konfirmasi
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Produk Tidak Ditemukan'),
              content: Text(
                'Barcode "$barcodeResult" tidak terdaftar. Apakah Anda ingin menambahkannya?',
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Batal'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  child: const Text('Tambah Produk Baru'),
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    // Pindah ke halaman AddTransaction dan kirim data barcode
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                AddProductScreen(initialBarcode: barcodeResult),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 3,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.home,
                color: index == 0 ? selectedItem : unselectedItem,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.box,
                color: index == 1 ? selectedItem : unselectedItem,
              ),
              label: 'Products',
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (index == 0) {
            _navigateToScanBarcodeThenShowDetail();
          } else if (index == 1) {
            _navigateToAddTransaction();
          }
        },
        shape: const CircleBorder(),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.tertiary,
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.primary,
              ],
              transform: const GradientRotation(pi / 4),
            ),
          ),
          child: Icon(
            index == 0 ? CupertinoIcons.barcode : CupertinoIcons.add,
            color: Colors.white,
          ),
        ),
      ),
      body: WidgetList[index],
    );
  }
}
