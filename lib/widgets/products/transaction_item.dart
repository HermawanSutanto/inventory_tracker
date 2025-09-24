import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:inventory_tracker/models/transaction_type.dart';
import 'package:inventory_tracker/widgets/products/item_image.dart';

// 1. Buat enum untuk jenis transaksi

class TransactionItem extends StatelessWidget {
  final String productName;
  final String date;
  final String category;
  final String transaction_id;
  final String imageUrl;

  final int stock;
  final TransactionType type;
  final VoidCallback onDelete; // 👈 Add a callback for the delete action

  const TransactionItem({
    required this.productName,
    required this.date,
    required this.category,
    required this.transaction_id,
    required this.imageUrl,

    required this.stock,
    required this.type,
    required this.onDelete, // 👈 Require the callback in the constructor
    super.key,
  });

  // New method to show the delete confirmation dialog using Cupertino
  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus transaksi "${productName}"?',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true, // This will make the text red
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onDelete(); // 👈 Call the onDelete callback
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showDeleteConfirmation(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ItemImage(imageUrl: imageUrl),
              const SizedBox(width: 8),
              Expanded(
                child: _ItemDetails(
                  productName: productName,
                  date: date,
                  type: type,
                  category: category,
                  transaction_id: transaction_id,
                ),
              ),
              _TransactionBadge(stock: stock, type: type),
            ],
          ),
        ),
      ),
    );
  }
}

// class _ItemIcon extends StatelessWidget {
//   const _ItemIcon();

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.yellow[600],
//             borderRadius: BorderRadius.circular(5),
//           ),
//         ),
//         const Icon(
//           CupertinoIcons.cart_fill,
//           color: Color.fromARGB(255, 249, 132, 37),
//           size: 12,
//         ),
//       ],
//     );
//   }
// }

class _ItemDetails extends StatelessWidget {
  final String productName;
  final String date;
  final String category;
  final String transaction_id;

  final TransactionType type;

  const _ItemDetails({
    required this.productName,
    required this.date,
    required this.category,
    required this.transaction_id,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    String dateLabel =
        type == TransactionType.inTransaction
            ? "Tanggal Masuk"
            : "Tanggal Keluar";

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    "Kategori:  $category",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "ID $transaction_id",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "$dateLabel: $date",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TransactionBadge extends StatelessWidget {
  final int stock;
  final TransactionType type;

  const _TransactionBadge({required this.stock, required this.type});

  @override
  Widget build(BuildContext context) {
    final bool isOut = type == TransactionType.outTransaction;
    final Color badgeColor =
        isOut ? Colors.greenAccent : const Color.fromARGB(255, 253, 192, 187);
    final Color iconColor = isOut ? Colors.green : Colors.red;
    final IconData icon =
        isOut ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown;

    return Container(
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          FaIcon(icon, size: 10, color: iconColor),
          const SizedBox(width: 2),
          Text(
            stock.toString(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
