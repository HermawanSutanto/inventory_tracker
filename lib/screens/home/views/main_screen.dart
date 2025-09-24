import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_tracker/data/data.dart';
import 'package:inventory_tracker/providers/product_provider.dart';
import 'package:inventory_tracker/screens/settings/settings_screen.dart';
import 'package:inventory_tracker/widgets/home/summary_card.dart';
import 'package:inventory_tracker/widgets/products/transaction_item.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // State yang tersisa hanyalah untuk UI, seperti query pencarian
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // 1. Akses provider untuk mendapatkan data dan fungsi
    final productProvider = Provider.of<ProductProvider>(context);

    // 2. Ambil data transaksi yang sudah diolah dari provider
    final allTransactions = productProvider.allEnrichedTransactions;

    // 3. Lakukan filter berdasarkan state UI lokal (_searchQuery)
    final filteredList =
        allTransactions.where((product) {
          final productName = product['name']?.toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          return productName.contains(query);
        }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child: Column(
            children: [
              const _HeaderSection(), // Widget ini tidak berubah
              const SizedBox(height: 20),
              // Widget ini tidak berubah, masih menggunakan dummy data
              _SummaryCardsSection(summaryData: summaryData),
              const SizedBox(height: 20),
              const _TransactionHeader(), // Widget ini tidak berubah
              const SizedBox(height: 10),
              Expanded(
                child: _TransactionList(
                  filteredProducts: filteredList,
                  // 4. Panggil method dari provider untuk aksi
                  onDelete:
                      (transactionId) =>
                          productProvider.deleteTransaction(transactionId),
                  getTransactionType:
                      (transactionId) =>
                          productProvider.getTransactionType(transactionId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellow[700],
                  ),
                ),
                Icon(CupertinoIcons.person_fill, color: Colors.yellow[800]),
              ],
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                Text(
                  "Hermawan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          icon: const Icon(CupertinoIcons.settings),
        ),
      ],
    );
  }
}

// Corrected _SummaryCardsSection widget
class _SummaryCardsSection extends StatelessWidget {
  final List<Map<String, dynamic>> summaryData; // Add this

  const _SummaryCardsSection({required this.summaryData}); // And this

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true, // This makes GridView take only the space it needs
      physics:
          const NeverScrollableScrollPhysics(), // Disables scrolling for nested GridView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: summaryData.length,
      itemBuilder: (context, index) {
        final data = summaryData[index];
        return SummaryCard(
          title: data['title']!,
          value: data['value']!,
          percentage: data['percentage']!,
          updateDate: data['updateDate']!,
        );
      },
    );
  }
}

class _TransactionHeader extends StatelessWidget {
  const _TransactionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Transactions",
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            "View All",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

// _TransactionList juga perlu sedikit penyesuaian untuk menampilkan 'quantity'
class _TransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> filteredProducts;
  final Function(String) onDelete;
  final Function(String) getTransactionType;

  const _TransactionList({
    required this.filteredProducts,
    required this.onDelete,
    required this.getTransactionType,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, int i) {
        final product = filteredProducts[i];

        // <-- 2. LAKUKAN KONVERSI DI SINI
        // Ambil Timestamp dari data
        final Timestamp timestamp = product['date'];
        // Ubah menjadi objek DateTime
        final DateTime dateTime = timestamp.toDate();
        // Format menjadi String yang mudah dibaca
        final String formattedDate = DateFormat(
          'dd MMM yyyy, HH:mm',
        ).format(dateTime);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TransactionItem(
            productName: product['name'],
            date: formattedDate,
            stock: product['quantity'], // PENTING: Gunakan 'quantity'
            category: product['category'],
            transaction_id: product['transaction_id'],
            imageUrl: product['imageUrl'],
            onDelete: () => onDelete(product['transaction_id']),
            type: getTransactionType(product['transaction_id']),
          ),
        );
      },
    );
  }
}
