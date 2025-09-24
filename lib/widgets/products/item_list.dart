import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// HAPUS IMPORT INI, KARENA TIDAK DIGUNAKAN LAGI
// import 'package:inventory_tracker/widgets/products/bottom_sheet/simple_bottom_sheet.dart';
import 'package:inventory_tracker/widgets/products/item_image.dart';

class ItemList extends StatelessWidget {
  final String productName;
  final String category;
  final String id;
  final int stock;
  final int capacity;
  final String imageUrl;

  const ItemList({
    super.key, // Gunakan super.key
    required this.productName,
    required this.category,
    required this.id,
    required this.stock,
    required this.capacity,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // HAPUS GestureDetector dan onTap DARI SINI
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ItemImage(imageUrl: imageUrl),
            const SizedBox(width: 8),
            Expanded(
              child: _ItemDetails(
                productName: productName,
                category: category,
                id: id,
                stock: stock,
                capacity: capacity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget _ItemDetails dan _StockBadge sudah benar, tidak perlu diubah.
class _ItemDetails extends StatelessWidget {
  final String productName;
  final String id;
  final String category;
  final int stock;
  final int capacity;

  const _ItemDetails({
    required this.productName,
    required this.category,
    required this.id,
    required this.stock,
    required this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    // Menghindari pembagian dengan nol jika kapasitas adalah 0
    final progressValue = capacity > 0 ? stock / capacity : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Kategori: $category",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "ID $id",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            _StockBadge(stock: stock),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progressValue.toDouble(),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          minHeight: 3,
        ),
      ],
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;

  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          const Text(
            "Stok:",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            stock.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
