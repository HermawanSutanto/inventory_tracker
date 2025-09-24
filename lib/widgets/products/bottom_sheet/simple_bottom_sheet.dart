import 'package:flutter/material.dart';
import 'package:inventory_tracker/widgets/products/bottom_sheet/bottom_detail_product.dart';

// Fungsi global untuk menampilkan bottom sheet
void showSimpleBottomSheet(
  BuildContext context, {
  required String productName,
  required String category,
  required String id,
  required String imageUrl,
  required int stock,
  required int capacity,
  bool initialStock = false, // Tambahkan parameter ini
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Untuk keyboard yang muncul
    builder: (BuildContext context) {
      return BottomDetailProduct(
        productName: productName,
        category: category,
        id: id,
        stock: stock,
        capacity: capacity,
        imageUrl: imageUrl,

        initialStock: initialStock, // Teruskan parameter ke widget
      );
    },
  );
}
