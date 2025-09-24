// 2. Data Transaksi Barang Keluar (Hanya berisi ID produk)
final List<Map<String, dynamic>> outProducts = [
  {
    'transaction_id': 'OUT111',
    'product_id':
        '800142384828', // Kunci Asing (Foreign Key) yang merujuk ke allProducts
    'date': '20/09/2025',
    'quantity': 2, // 'stock' diubah menjadi 'quantity' agar lebih jelas
  },
  {
    'transaction_id': 'OUT112',
    'product_id': '800142384827',
    'date': '19/09/2025',
    'quantity': 1,
  },
  {
    'transaction_id': 'OUT113',
    'product_id': '800142384826',
    'date': '18/09/2025',
    'quantity': 5,
  },
];

// 3. Data Transaksi Barang Masuk (Hanya berisi ID produk)
final List<Map<String, dynamic>> inProducts = [
  {
    'transaction_id': 'IN221',
    'product_id':
        '800142384827', // Merujuk ke produk 'Anting Stud' di allProducts
    'date': '21/09/2025',
    'quantity': 10,
  },
  {
    'transaction_id': 'IN222',
    'product_id':
        '800142384826', // Merujuk ke produk 'Jam Tangan' di allProducts
    'date': '18/09/2025',
    'quantity': 50,
  },
];
// Dummy data untuk semua produk di toko
final List<Map<String, dynamic>> allProducts = [
  {
    'name': 'Cincin Perak',
    'category': 'Perhiasan',
    'id': '800142384828',
    'stock': 75,
    'capacity': 100,
    'imageUrl':
        'https://images.unsplash.com/photo-1624823183493-ed5832f48f18?q=80&w=2080&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Path yang benar
  },
  {
    'name': 'Gelang Kulit',
    'category': 'Aksesoris',
    'id': '800142384827',
    'stock': 40,
    'capacity': 50,
    'imageUrl':
        'https://images.unsplash.com/photo-1624823183493-ed5832f48f18?q=80&w=2080&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  },
  {
    'name': 'Kalung Emas',
    'category': 'Perhiasan',
    'id': '800142384826',
    'stock': 15,
    'capacity': 30,
    'imageUrl':
        'https://plus.unsplash.com/premium_photo-1681276170683-706111cf496e?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  },
  {
    'name': 'Anting Stud',
    'category': 'Perhiasan',
    'id': '800142384825',
    'stock': 90,
    'capacity': 120,
    'imageUrl':
        'https://images.unsplash.com/photo-1624823183493-ed5832f48f18?q=80&w=2080&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  },
  {
    'name': 'Jam Tangan',
    'category': 'Aksesoris',
    'id': '800142384824',
    'stock': 25,
    'capacity': 60,
    'imageUrl':
        'https://images.unsplash.com/photo-1624823183493-ed5832f48f18?q=80&w=2080&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  },
];

// Data dummy untuk setiap kartu
final List<Map<String, dynamic>> summaryData = [
  {
    'title': "Total Products",
    'value': "250",
    'percentage': "+10%",
    'updateDate': "Today",
  },
  {
    'title': "Total Terjual",
    'value': "25",
    'percentage': "+5%",
    'updateDate': "Yesterday",
  },
  {
    'title': "Stok Menipis",
    'value': "50",
    'percentage': "+2%",
    'updateDate': "Today",
  },
  {
    'title': "Stok Diperbarui",
    'value': "100",
    'percentage': "+15%",
    'updateDate': "Today",
  },
];
