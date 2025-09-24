// lib/providers/product_provider.dart (VERSI FIREBASE)

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:inventory_tracker/models/transaction_type.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Instance Storage
  // --- METHOD BARU UNTUK UPLOAD GAMBAR ---
  Future<String?> _uploadImage(String filePath, String productId) async {
    try {
      final file = File(filePath);
      // Buat referensi lokasi penyimpanan di Firebase Storage
      final ref = _storage
          .ref()
          .child('product_images')
          .child('$productId.jpg');

      // Upload file
      await ref.putFile(file);
      // Dapatkan URL download publiknya
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Ganti List lokal dengan stream dari Firestore
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _inProducts = [];
  List<Map<String, dynamic>> _outProducts = [];

  bool _isLoading = true; // State untuk loading awal
  bool get isLoading => _isLoading;

  ProductProvider() {
    // Dengarkan perubahan data secara real-time dari Firestore
    _listenToProducts();
    _listenToTransactions();
  }

  void _listenToProducts() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      _allProducts =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      _isLoading = false; // Berhenti loading setelah data pertama diterima
      notifyListeners();
    });
  }

  void _listenToTransactions() {
    _firestore.collection('transactions_in').snapshots().listen((snapshot) {
      _inProducts =
          snapshot.docs
              .map((doc) => {'transaction_id': doc.id, ...doc.data()})
              .toList();
      notifyListeners();
    });
    _firestore.collection('transactions_out').snapshots().listen((snapshot) {
      _outProducts =
          snapshot.docs
              .map((doc) => {'transaction_id': doc.id, ...doc.data()})
              .toList();
      notifyListeners();
    });
  }

  List<Map<String, dynamic>> get allProductsData {
    if (_selectedCategory == null || _selectedCategory == 'Semua Kategori') {
      return _allProducts;
    }
    return _allProducts
        .where((product) => product['category'] == _selectedCategory)
        .toList();
  }

  List<Map<String, dynamic>> get inProductsData => _inProducts;
  List<Map<String, dynamic>> get outProductsData => _outProducts;
  // 1. TAMBAHKAN STATE UNTUK FILTER
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;
  // DIUBAH: dari List<Map> menjadi List<Map<String, dynamic>>
  // 2. TAMBAHKAN GETTER UNTUK MENDAPATKAN SEMUA KATEGORI UNIK
  List<String> get uniqueCategories {
    final categories = _allProducts.map((p) => p['category'] as String).toSet();
    return [
      'Semua Kategori',
      ...categories,
    ]; // Tambahkan 'Semua Kategori' di awal
  }

  Future<void> updateProductDetails(Map<String, dynamic> productData) async {
    // Salin data agar tidak mengubah map aslinya
    final dataToUpdate = Map<String, dynamic>.from(productData);
    // Ambil dan hapus ID dari map, karena ID tidak perlu di-update di dalam field dokumen
    final productId = dataToUpdate.remove('id');

    if (productId != null) {
      await _firestore
          .collection('products')
          .doc(productId)
          .update(dataToUpdate);
    }
  }

  List<Map<String, dynamic>> getEnrichedTransactions(
    List<Map<String, dynamic>> transactions,
  ) {
    final enriched =
        transactions
            .map((transaction) {
              final productDetails = _allProducts.firstWhere(
                (product) => product['id'] == transaction['product_id'],
                orElse: () => <String, dynamic>{}, // Beri tipe map kosong
              );
              if (productDetails.isNotEmpty) {
                return {...productDetails, ...transaction};
              }
              return <String, dynamic>{}; // Beri tipe map kosong
            })
            .where((item) => item.isNotEmpty)
            .toList();

    // Pastikan hasil akhirnya memiliki tipe yang benar
    return List<Map<String, dynamic>>.from(enriched);
  }

  // Getter untuk transaksi KELUAR yang sudah di-enrich (untuk ProductList)
  // MODIFIKASI GETTER ENRICHED
  List<Map<String, dynamic>> get enrichedOutTransactions {
    var enriched = getEnrichedTransactions(_outProducts);
    if (_selectedCategory == null || _selectedCategory == 'Semua Kategori') {
      return enriched;
    }
    return enriched.where((t) => t['category'] == _selectedCategory).toList();
  }

  // Getter untuk transaksi MASUK yang sudah di-enrich (untuk ProductList)
  List<Map<String, dynamic>> get enrichedInTransactions {
    var enriched = getEnrichedTransactions(_inProducts);
    if (_selectedCategory == null || _selectedCategory == 'Semua Kategori') {
      return enriched;
    }
    return enriched.where((t) => t['category'] == _selectedCategory).toList();
  }

  // DIUBAH: dari List<Map> menjadi List<Map<String, dynamic>>
  List<Map<String, dynamic>> get allEnrichedTransactions {
    final combined = [..._inProducts, ..._outProducts];
    final enriched = getEnrichedTransactions(combined);
    enriched.sort((a, b) => b['date'].compareTo(a['date']));
    return enriched;
  }

  // void deleteTransaction(String transactionId) {
  //   _inProducts.removeWhere((item) => item['transaction_id'] == transactionId);
  //   _outProducts.removeWhere((item) => item['transaction_id'] == transactionId);
  //   notifyListeners();
  // }

  TransactionType getTransactionType(String transactionId) {
    return _inProducts.any((item) => item['transaction_id'] == transactionId)
        ? TransactionType.inTransaction
        : TransactionType.outTransaction;
  }

  // 4. TAMBAHKAN METHOD UNTUK MENGUBAH FILTER
  void applyCategoryFilter(String? category) {
    if (category == 'Semua Kategori') {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    notifyListeners(); // Beri tahu UI untuk update
  }

  List<String> get categorySuggestions {
    return _allProducts.map((p) => p['category'] as String).toSet().toList();
  }

  Map<String, dynamic>? findProductByBarcode(String barcode) {
    try {
      return _allProducts.firstWhere((p) => p['id'] == barcode);
    } catch (e) {
      return null;
    }
  }

  Future<void> addNewProduct({
    required String id,
    required String name,
    required String category,
    required int initialStock,
    String? imagePath, // Ganti nama dari imageUrl ke imagePath agar lebih jelas
  }) async {
    String? finalImageUrl;

    // Jika ada gambar yang dipilih, upload dulu
    if (imagePath != null) {
      finalImageUrl = await _uploadImage(imagePath, id);
    }

    final newProduct = {
      'name': name,
      'category': category,
      'stock': initialStock,
      'capacity': initialStock + 50,
      'imageUrl': finalImageUrl ?? 'https://via.placeholder.com/150',
    };
    // Gunakan 'set' dengan 'doc(id)' untuk membuat dokumen dengan ID custom (barcode)
    await _firestore.collection('products').doc(id).set(newProduct);
  }

  Future<void> recordIncomingStock({
    required String id,
    required int quantity,
  }) async {
    // 1. Buat catatan transaksi
    final newTransaction = {
      'product_id': id,
      'date': Timestamp.now(), // Gunakan Timestamp Firebase
      'quantity': quantity,
    };
    await _firestore.collection('transactions_in').add(newTransaction);

    // 2. Update total stok di dokumen produk
    await _firestore.collection('products').doc(id).update({
      'stock': FieldValue.increment(quantity),
    });
  }

  Future<void> recordOutgoingStock({
    required String id,
    required int quantity,
  }) async {
    final newTransaction = {
      'product_id': id,
      'date': Timestamp.now(),
      'quantity': quantity,
    };
    await _firestore.collection('transactions_out').add(newTransaction);

    // Gunakan increment negatif untuk mengurangi stok
    await _firestore.collection('products').doc(id).update({
      'stock': FieldValue.increment(-quantity),
    });
  }

  // lib/providers/product_provider.dart

  // Ubah method ini
  Future<void> deleteTransaction(String transactionId) async {
    // Biarkan provider yang menentukan tipenya
    final type = getTransactionType(transactionId);
    String collectionPath =
        type == TransactionType.inTransaction
            ? 'transactions_in'
            : 'transactions_out';

    // Sisa logikanya sama...
    final doc =
        await _firestore.collection(collectionPath).doc(transactionId).get();
    if (doc.exists) {
      final data = doc.data()!;
      final productId = data['product_id'];
      final quantity = data['quantity'];

      await _firestore.collection(collectionPath).doc(transactionId).delete();

      int stockChange =
          type == TransactionType.inTransaction ? -quantity : quantity;
      await _firestore.collection('products').doc(productId).update({
        'stock': FieldValue.increment(stockChange),
      });
    }
  }

  void addStockToProduct({required String id, required int quantity}) {
    try {
      final productIndex = _allProducts.indexWhere((p) => p['id'] == id);
      if (productIndex != -1) {
        _allProducts[productIndex]['stock'] += quantity;
        notifyListeners(); // Update UI
      }
    } catch (e) {
      // Handle jika produk tiba-tiba tidak ada
      print('Error adding stock: $e');
    }
  }
}
