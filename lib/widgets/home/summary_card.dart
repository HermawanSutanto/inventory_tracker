import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final String updateDate;

  const SummaryCard({
    required this.title,
    required this.value,
    required this.percentage,
    required this.updateDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    Color percentageColor;
    IconData percentageIcon;
    Color cardColor = Colors.white; // Warna kartu default

    // Logika untuk menentukan ikon dan warna berdasarkan judul
    switch (title) {
      case "Total Products":
        iconData = CupertinoIcons.cart_fill;
        iconColor = const Color.fromARGB(255, 249, 132, 37);
        percentageIcon = CupertinoIcons.arrow_up;
        percentageColor = Colors.green;
        break;
      case "Stok Diperbarui":
        iconData = CupertinoIcons.arrow_down_circle_fill;
        iconColor = Colors.red;
        percentageIcon = CupertinoIcons.arrow_down;
        percentageColor = Colors.red;
        break;
      case "Stok Menipis":
        iconData = CupertinoIcons.square_stack_3d_down_right_fill;
        iconColor = Colors.orange;
        percentageIcon = CupertinoIcons.arrow_down;
        percentageColor = Colors.red;
        break;
      case "Total Terjual":
        iconData = CupertinoIcons.arrow_up_circle_fill;
        iconColor = Colors.green;
        percentageIcon = CupertinoIcons.arrow_up;
        percentageColor = Colors.green;
        break;
      default:
        iconData = CupertinoIcons.info;
        iconColor = Colors.grey;
        percentageIcon = CupertinoIcons.arrow_up;
        percentageColor = Colors.green;
        break;
    }

    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.grey.shade300,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconColor.withOpacity(0.2),
                      ),
                    ),
                    Icon(iconData, color: iconColor, size: 12),
                  ],
                ),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: percentageColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(percentageIcon, color: percentageColor, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          percentage,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: percentageColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              decoration: BoxDecoration(color: Colors.grey.shade100),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Update: ",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                Text(
                  updateDate,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
