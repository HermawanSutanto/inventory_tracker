// lib/providers/product_provider.dart (VERSI SUPABASE STORAGE)

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Hapus atau komentari ini
import 'package:flutter/foundation.dart';
import 'package:inventory_tracker/models/transaction_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Tambahkan dependency Supabase

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Hapus instance Firebase Storage
  // final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- METHOD UPLOAD GAMBAR DIGANTI DENGAN SUPABASE STORAGE ---
  Future<String?> _uploadImage(String filePath, String productId) async {
    try {
      final supabase = Supabase.instance.client;
      final file = File(filePath);
      // Dapatkan ekstensi file secara dinamis
      final fileExtension = filePath.split('.').last;
      // Tentukan path penyimpanan di Supabase Storage
      final path = 'product_images/$productId.$fileExtension';

      // Upload file ke bucket 'product_images'
      // 'upsert: true' akan menimpa file jika sudah ada dengan nama yang sama
      await supabase.storage
          .from('product_images')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Dapatkan URL publik dari file yang baru di-upload
      final downloadUrl = supabase.storage
          .from('product_images')
          .getPublicUrl(path);

      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      return null;
    }
  }

  // Ganti List lokal dengan stream dari Firestore
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _inProducts = [];
  List<Map<String, dynamic>> _outProducts = [];

  bool _isLoading = true; // State untuk loading awal
  bool get isLoading => _isLoading;
  String? _errorMessage; // State untuk menyimpan pesan error

  ProductProvider() {
    // Dengarkan perubahan data secara real-time dari Firestore
    _listenToProducts();
    _listenToTransactions();
  }

  // --- LISTENERS DENGAN PENANGANAN ERROR ---
  void _listenToProducts() {
    _firestore
        // --- TAMBAHKAN FILTER .where() DI SINI ---
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen(
          (snapshot) {
            _allProducts =
                snapshot.docs
                    .map((doc) => {'id': doc.id, ...doc.data()})
                    .toList();
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            print("Error listening to products: $error");
            _errorMessage = "Gagal memuat data produk. Periksa koneksi Anda.";
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void _listenToTransactions() {
    _firestore
        .collection('transactions_in')
        .snapshots()
        .listen(
          (snapshot) {
            _inProducts =
                snapshot.docs
                    .map((doc) => {'transaction_id': doc.id, ...doc.data()})
                    .toList();
            notifyListeners();
          },
          onError: (error) {
            print("Error listening to incoming transactions: $error");
            _errorMessage = "Gagal memuat transaksi masuk.";
            notifyListeners();
          },
        );

    _firestore
        .collection('transactions_out')
        .snapshots()
        .listen(
          (snapshot) {
            _outProducts =
                snapshot.docs
                    .map((doc) => {'transaction_id': doc.id, ...doc.data()})
                    .toList();
            notifyListeners();
          },
          onError: (error) {
            print("Error listening to outgoing transactions: $error");
            _errorMessage = "Gagal memuat transaksi keluar.";
            notifyListeners();
          },
        );
  }

  int get totalUniqueProducts => _allProducts.length;

  // Getter untuk jumlah total stok semua barang
  int get totalStock {
    if (_allProducts.isEmpty) return 0;
    return _allProducts.map((p) => p['stock'] as int).reduce((a, b) => a + b);
  }

  // Getter untuk jumlah transaksi masuk hari ini
  int get incomingTransactionsToday {
    final now = DateTime.now();
    return _inProducts.where((t) {
      final date = (t['date'] as Timestamp).toDate();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;
  }

  // Getter untuk jumlah transaksi keluar hari ini
  int get outgoingTransactionsToday {
    final now = DateTime.now();
    return _outProducts.where((t) {
      final date = (t['date'] as Timestamp).toDate();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;
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

  // Versi yang lebih cepat
  List<Map<String, dynamic>> getEnrichedTransactions(
    List<Map<String, dynamic>> transactions,
  ) {
    // Buat lookup map untuk pencarian instan O(1)
    final productMap = {
      for (var product in _allProducts) product['id']: product,
    };

    final enriched =
        transactions
            .map((transaction) {
              // Pencarian ini sekarang sangat cepat
              final productDetails = productMap[transaction['product_id']];
              if (productDetails != null) {
                return {...productDetails, ...transaction};
              }
              return null;
            })
            .where((item) => item != null)
            .cast<Map<String, dynamic>>()
            .toList();

    return enriched;
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
      // Cari produk di mana field 'barcode' cocok
      return _allProducts.firstWhere((p) => p['barcode'] == barcode);
    } catch (e) {
      return null; // Tidak ditemukan
    }
  }

  Future<void> addNewProduct({
    // 'id' dihilangkan, diganti dengan 'barcode'
    required String barcode,
    required String name,
    required String category,
    required int initialStock,
    String? imagePath,
  }) async {
    // 1. Buat dokumen baru di Firestore & biarkan Firestore membuat ID unik
    final newProductRef = _firestore.collection('products').doc();
    final newProductId = newProductRef.id; // Ini adalah ID unik yang baru

    String? finalImageUrl;

    if (imagePath != null) {
      // Gunakan ID unik yang baru untuk nama file gambar
      finalImageUrl = await _uploadImage(imagePath, newProductId);
    }

    final newProduct = {
      'barcode': barcode, // Simpan barcode sebagai field biasa
      'name': name,
      'category': category,
      'stock': 0,
      'capacity': 0,
      'imageUrl': finalImageUrl ?? 'https://via.placeholder.com/150',
      'isActive': true, // <-- TAMBAHKAN BARIS INI
    };

    // 2. Gunakan .set() pada referensi dokumen yang baru dibuat
    await newProductRef.set(newProduct);

    if (initialStock > 0) {
      // 3. Gunakan ID unik yang baru untuk mencatat transaksi
      await recordIncomingStock(id: newProductId, quantity: initialStock);
    }
  }

  Future<void> recordIncomingStock({
    required String id,
    required int quantity,
  }) async {
    // Bagian pembuatan transaksi tetap sama
    final newTransaction = {
      'product_id': id,
      'date': Timestamp.now(),
      'quantity': quantity,
    };
    await _firestore.collection('transactions_in').add(newTransaction);

    // --- PERUBAHAN DI SINI ---
    // Update total stok DAN kapasitas di dokumen produk
    await _firestore.collection('products').doc(id).update({
      'stock': FieldValue.increment(quantity),
      'capacity': FieldValue.increment(quantity), // Tambahkan baris ini
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

  Future<void> deleteTransaction(String transactionId) async {
    final type = getTransactionType(transactionId);
    String collectionPath =
        type == TransactionType.inTransaction
            ? 'transactions_in'
            : 'transactions_out';

    final doc =
        await _firestore.collection(collectionPath).doc(transactionId).get();
    if (doc.exists) {
      final data = doc.data()!;
      final productId = data['product_id'];
      final quantity = data['quantity'];

      await _firestore.collection(collectionPath).doc(transactionId).delete();

      // --- PERUBAHAN DI SINI ---
      if (type == TransactionType.inTransaction) {
        // Jika yang dihapus adalah transaksi MASUK, kurangi stock DAN capacity
        await _firestore.collection('products').doc(productId).update({
          'stock': FieldValue.increment(-quantity),
          'capacity': FieldValue.increment(-quantity), // Tambahkan baris ini
        });
      } else {
        // Jika yang dihapus transaksi KELUAR, hanya kembalikan stock
        await _firestore.collection('products').doc(productId).update({
          'stock': FieldValue.increment(quantity),
        });
      }
    }
  }

  void addStockToProduct({required String barcode, required int quantity}) {
    try {
      final productIndex = _allProducts.indexWhere(
        (p) => p['barcode'] == barcode,
      );
      if (productIndex != -1) {
        _allProducts[productIndex]['stock'] += quantity;
        notifyListeners(); // Update UI
      }
    } catch (e) {
      // Handle jika produk tiba-tiba tidak ada
      print('Error adding stock: $e');
    }
  }

  Future<void> deactivateProduct(String productId) async {
    try {
      final productDocRef = _firestore.collection('products').doc(productId);

      // Cukup update field 'isActive' menjadi false
      await productDocRef.update({'isActive': false});

      print('Produk $productId berhasil dinonaktifkan.');
    } catch (e) {
      print('Error saat menonaktifkan produk: $e');
    }
  }

  Future<void> activateProduct(String productId) async {
    try {
      final productDocRef = _firestore.collection('products').doc(productId);

      // Update field 'isActive' kembali menjadi true
      await productDocRef.update({'isActive': true});

      print('Produk $productId berhasil diaktifkan kembali.');
    } catch (e) {
      print('Error saat mengaktifkan produk: $e');
    }
  }

  // Future<void> deleteProduct(String productId) async {
  //   try {
  //     // 1. Ambil referensi dokumen produk untuk mendapatkan URL gambar sebelum dihapus
  //     final productDocRef = _firestore.collection('products').doc(productId);
  //     final productSnapshot = await productDocRef.get();
  //     if (!productSnapshot.exists) {
  //       print('Produk tidak ditemukan, tidak bisa menghapus.');
  //       return;
  //     }
  //     final imageUrl = productSnapshot.data()?['imageUrl'] as String?;

  //     // Mulai batch write untuk operasi atomik di Firestore
  //     final batch = _firestore.batch();

  //     // 2. Hapus semua transaksi masuk (transactions_in) yang terkait
  //     final inTransactions =
  //         await _firestore
  //             .collection('transactions_in')
  //             .where('product_id', isEqualTo: productId)
  //             .get();
  //     for (final doc in inTransactions.docs) {
  //       batch.delete(doc.reference);
  //     }

  //     // 3. Hapus semua transaksi keluar (transactions_out) yang terkait
  //     final outTransactions =
  //         await _firestore
  //             .collection('transactions_out')
  //             .where('product_id', isEqualTo: productId)
  //             .get();
  //     for (final doc in outTransactions.docs) {
  //       batch.delete(doc.reference);
  //     }

  //     // 4. Hapus dokumen produk itu sendiri
  //     batch.delete(productDocRef);

  //     // 5. Jalankan semua operasi hapus di Firestore
  //     await batch.commit();

  //     // 6. Hapus gambar dari Supabase Storage jika ada
  //     if (imageUrl != null && !imageUrl.contains('placeholder.com')) {
  //       // Ekstrak path file dari URL lengkap
  //       final uri = Uri.parse(imageUrl);
  //       final filePath = uri.pathSegments
  //           .sublist(uri.pathSegments.indexOf('product_images'))
  //           .join('/');

  //       final supabase = Supabase.instance.client;
  //       await supabase.storage.from('product_images').remove([filePath]);
  //       print('Gambar berhasil dihapus dari Supabase: $filePath');
  //     }
  //   } catch (e) {
  //     print('Error saat menghapus produk: $e');
  //     // Opsional: Lemparkan error agar bisa ditangani di UI
  //     // throw Exception('Gagal menghapus produk.');
  //   }
  // }
}
