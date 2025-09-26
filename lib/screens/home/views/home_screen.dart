import 'dart:math';

import 'package:inventory_tracker/providers/product_provider.dart';
import 'package:inventory_tracker/screens/transaction/views/add_product.dart';
import 'package:inventory_tracker/screens/transaction/views/scan_barcode.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventory_tracker/screens/home/views/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_tracker/screens/products/views/product_list.dart';
import 'package:inventory_tracker/widgets/products/bottom_sheet/bottom_detail_product.dart';
import 'package:inventory_tracker/widgets/products/bottom_sheet/simple_bottom_sheet.dart';
import 'package:provider/provider.dart';

// Asumsi: Anda memiliki file 'data.dart' dengan list allProducts

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
  // Map<String, dynamic>? _findProductById(String barcode) {
  //   try {
  //     return allProducts.firstWhere((product) => product['id'] == barcode);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  void _navigateToScanBarcodeThenShowDetail() async {
    final barcodeResult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanBarcode()),
    );

    if (barcodeResult != null && mounted) {
      // 'mounted' check is a good practice
      // 1. Ambil ProductProvider dari context
      // Gunakan context.read karena kita hanya memanggil fungsi, tidak perlu me-listen perubahan
      final provider = context.read<ProductProvider>();

      // 2. Gunakan metode dari provider untuk mencari produk berdasarkan barcode
      final productData = provider.findProductByBarcode(barcodeResult);

      if (productData != null) {
        // Jika produk ditemukan, tampilkan bottom sheet
        // showSimpleBottomSheet sekarang akan menggunakan BottomDetailProduct
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder:
              (ctx) => BottomDetailProduct(
                // Data dari productData sudah sesuai
                productName: productData['name']!,
                category: productData['category']!,
                id: productData['id']!, // Ini adalah ID Unik Firestore
                barcode: productData['barcode']!, // Ini adalah barcode
                stock: productData['stock']!,
                capacity: productData['capacity']!,
                imageUrl: productData['imageUrl'],
                initialStock: true, // Agar langsung ke mode 'adjustStock'
                // Sambungkan callback ke provider
                onStockOut:
                    (productId, quantity) => provider.recordOutgoingStock(
                      id: productId,
                      quantity: quantity,
                    ),
                onStockIn:
                    (productId, quantity) => provider.recordIncomingStock(
                      id: productId,
                      quantity: quantity,
                    ),
                onDelete: (productId) => provider.deactivateProduct(productId),
                onDetailsSaved:
                    (updatedData) => provider.updateProductDetails(updatedData),
              ),
        );
      } else {
        // Logika jika produk tidak ditemukan tetap sama, ini sudah benar.
        showCupertinoDialog(
          context: context,
          builder: (dialogContext) {
            return CupertinoAlertDialog(
              title: const Text('Produk Tidak Ditemukan'),
              content: Text(
                'Barcode "$barcodeResult" tidak terdaftar. Apakah Anda ingin menambahkannya?',
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Batal'),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                CupertinoDialogAction(
                  child: const Text('Tambah Produk Baru'),
                  onPressed: () {
                    Navigator.pop(dialogContext); // Tutup dialog
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
