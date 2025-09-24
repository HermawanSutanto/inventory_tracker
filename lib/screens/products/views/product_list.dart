import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // <-- 1. IMPORT THIS PACKAGE
import 'package:inventory_tracker/models/transaction_type.dart';
import 'package:inventory_tracker/providers/product_provider.dart';
import 'package:inventory_tracker/widgets/products/bottom_sheet/bottom_detail_product.dart';
import 'package:inventory_tracker/widgets/products/item_list.dart';
import 'package:inventory_tracker/widgets/products/transaction_item.dart';
import 'package:provider/provider.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  String _searchQuery = "";
  // Method untuk menampilkan Bottom Sheet Filter
  void _showFilterBottomSheet(BuildContext context) {
    // Gunakan context.read() untuk aksi di luar build method
    // Ini "membaca" provider sekali saja tanpa mendengarkan perubahan
    final productProvider = context.read<ProductProvider>();
    final categories = productProvider.uniqueCategories;
    final activeCategory = productProvider.selectedCategory ?? 'Semua Kategori';

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (itemCtx, index) {
            final category = categories[index];
            return ListTile(
              title: Text(category),
              trailing:
                  category == activeCategory
                      ? const Icon(Icons.check, color: Colors.orange)
                      : null,
              onTap: () {
                // Di dalam onTap, kita panggil fungsi dari provider yang sudah kita "baca"
                productProvider.applyCategoryFilter(category);
                Navigator.of(ctx).pop();
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Akses provider di paling atas
    final productProvider = Provider.of<ProductProvider>(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Column(
          children: [
            _SearchBar(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onFilterPressed: () => _showFilterBottomSheet(context),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _ProductTabs(
                searchQuery: _searchQuery,
                // Kirim data langsung dari provider
                allProducts: productProvider.allProductsData,
                outProducts:
                    productProvider.enrichedOutTransactions, // Data baru
                inProducts: productProvider.enrichedInTransactions, // Data baru
                // Kirim fungsi delete dari provider
                onDelete:
                    (transactionId) =>
                        productProvider.deleteTransaction(transactionId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _SearchBar, _MainListProduct remain StatelessWidget as they don't hold state
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterPressed; // Callback untuk tombol filter

  const _SearchBar({required this.onChanged, required this.onFilterPressed});
  // Callback untuk tombol filter

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                FontAwesomeIcons.search,
                size: 16,
                color: Colors.grey,
              ),
              hintText: "Cari Produk",
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.filter, color: Colors.grey),
          onPressed: onFilterPressed,
        ),
      ],
    );
  }
}

class _ProductTabs extends StatelessWidget {
  final String searchQuery;
  final List<Map<String, dynamic>> allProducts;
  final List<Map<String, dynamic>> outProducts;
  final List<Map<String, dynamic>> inProducts;
  final Function(String) onDelete;

  const _ProductTabs({
    required this.searchQuery,
    required this.allProducts,
    required this.outProducts,
    required this.inProducts,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Colors.transparent,
            labelColor: Color.fromARGB(255, 255, 139, 30),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: Color.fromARGB(255, 255, 227, 201),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: "Semua Barang"),
              Tab(text: "Barang Keluar"),
              Tab(text: "Barang Masuk"),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: TabBarView(
              children: [
                _MainListProduct(
                  searchQuery: searchQuery,
                  productsData: allProducts,
                ),
                // Widget _TransactionHistoryList menjadi jauh lebih sederhana
                _TransactionHistoryList(
                  searchQuery: searchQuery,
                  enrichedTransactionData: outProducts,
                  type: TransactionType.outTransaction,
                  onDelete: onDelete,
                ),
                _TransactionHistoryList(
                  searchQuery: searchQuery,
                  enrichedTransactionData: inProducts,
                  type: TransactionType.inTransaction,
                  onDelete: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainListProduct extends StatelessWidget {
  final String searchQuery;
  final List<Map<String, dynamic>> productsData;

  const _MainListProduct({
    required this.searchQuery,
    required this.productsData,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.read<ProductProvider>();

    final filteredProducts =
        productsData.where((product) {
          final productName = product['name']!.toLowerCase();
          final query = searchQuery.toLowerCase();
          return productName.contains(query);
        }).toList();

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, int i) {
        final product = filteredProducts[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder:
                    (ctx) => BottomDetailProduct(
                      productName: product['name'],
                      id: product['id'],
                      category: product['category'],
                      stock: product['stock'],
                      capacity: product['capacity'],
                      imageUrl: product['imageUrl'],
                      onStockOut: (productId, quantity) {
                        productProvider.recordOutgoingStock(
                          id: productId,
                          quantity: quantity,
                        );
                      },
                      onStockIn: (productId, quantity) {
                        productProvider.recordIncomingStock(
                          id: productId,
                          quantity: quantity,
                        );
                      },
                      onDetailsSaved: (updatedData) {
                        productProvider.updateProductDetails(updatedData);
                      },
                      onDelete: (productId) {
                        productProvider
                            .deleteProduct(productId)
                            .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Produk berhasil dihapus!'),
                                ),
                              );
                            })
                            .catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal menghapus produk: $error',
                                  ),
                                ),
                              );
                            });
                      },
                    ),
              );
            },
            child: ItemList(
              productName: product['name'],
              stock: product['stock'],
              category: product['category'],
              id: product['id'],
              capacity: product['capacity'],
              imageUrl: product['imageUrl'],
            ),
          ),
        );
      },
    );
  }
}

// _TransactionHistoryList sekarang sangat sederhana
class _TransactionHistoryList extends StatelessWidget {
  final String searchQuery;
  // Menerima data yang SUDAH di-enrich
  final List<Map<String, dynamic>> enrichedTransactionData;
  final TransactionType type;
  final Function(String) onDelete; // Menerima ID transaksi

  const _TransactionHistoryList({
    required this.searchQuery,
    required this.enrichedTransactionData,
    required this.type,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Cukup lakukan filter
    final filteredTransactions =
        enrichedTransactionData.where((transaction) {
          final productName = (transaction['name'] as String).toLowerCase();
          final query = searchQuery.toLowerCase();
          return productName.contains(query);
        }).toList();

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, int i) {
        final transactionItem = filteredTransactions[i];

        // <-- 2. LAKUKAN KONVERSI DI SINI
        // Ambil Timestamp dari data
        final Timestamp timestamp = transactionItem['date'];
        // Ubah menjadi objek DateTime
        final DateTime dateTime = timestamp.toDate();
        // Format menjadi String yang mudah dibaca
        final String formattedDate = DateFormat(
          'dd MMM yyyy, HH:mm',
        ).format(dateTime);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TransactionItem(
            productName: transactionItem['name'],
            date: formattedDate, // <-- 3. GUNAKAN STRING YANG SUDAH DIFORMAT
            stock: transactionItem['quantity'],
            category: transactionItem['category'],
            transaction_id: transactionItem['transaction_id'],
            imageUrl: transactionItem['imageUrl'],
            // Langsung panggil onDelete dengan ID unik
            onDelete: () => onDelete(transactionItem['transaction_id']),
            type: type,
          ),
        );
      },
    );
  }
}
