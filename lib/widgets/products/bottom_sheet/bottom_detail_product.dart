import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:inventory_tracker/widgets/products/item_image.dart';

// 1. Definisikan Enum untuk mengelola mode tampilan
enum DetailSheetMode { display, adjustStock, editForm }

enum AdjustmentType { stockOut, stockIn }

class BottomDetailProduct extends StatefulWidget {
  final String productName;
  final String id;
  final String category;
  final int stock;
  final int capacity;
  final String imageUrl;
  final bool initialStock;

  // 2. Tambahkan callback terpisah
  final Function(String productId, int quantity)? onStockOut;

  final Function(String productId, int quantity)? onStockIn;

  final Function(Map<String, dynamic> updatedData)? onDetailsSaved;

  const BottomDetailProduct({
    super.key,
    required this.productName,
    required this.category,
    required this.id,
    required this.stock,
    required this.capacity,
    required this.imageUrl,
    this.onStockOut,
    this.onStockIn,
    this.onDetailsSaved,
    this.initialStock = false,
  });

  @override
  State<BottomDetailProduct> createState() => _BottomDetailProductState();
}

class _BottomDetailProductState extends State<BottomDetailProduct> {
  // 3. Ganti _isEditing dengan _mode
  late DetailSheetMode _mode;
  late String imageUrl;
  late bool _intitialStock = widget.initialStock;
  late int _stockAdjustment;
  late TextEditingController _stockAdjustmentController;
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _capacityController;
  late AdjustmentType _adjustmentType; // <-- State baru untuk tipe penyesuaian

  // Controller untuk form edit detail (akan digunakan nanti)
  // late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _intitialStock == false
        ? _mode = DetailSheetMode.display
        : _mode =
            DetailSheetMode
                .adjustStock // Mode awal
                ; // Mode awal
    imageUrl = widget.imageUrl;
    _stockAdjustment = 0;
    _adjustmentType = AdjustmentType.stockOut; // Default ke barang keluar

    _stockAdjustmentController = TextEditingController(text: '0');

    _nameController = TextEditingController(text: widget.productName);
    _categoryController = TextEditingController(text: widget.category);
    _capacityController = TextEditingController(
      text: widget.capacity.toString(),
    );
  }

  @override
  void dispose() {
    _stockAdjustmentController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _updateStockAdjustment(int change) {
    final proposedAdjustment = _stockAdjustment + change;
    // Validasi hanya berlaku untuk barang keluar
    if (_adjustmentType == AdjustmentType.stockOut &&
        (widget.stock - proposedAdjustment < 0)) {
      return; // Hentikan jika stok akan negatif
    }
    // // Validasi: Jangan biarkan stok baru menjadi negatif
    // if (widget.stock - proposedAdjustment < 0) {
    //   return; // Hentikan fungsi jika akan membuat stok negatif
    // }
    // Penyesuaian tidak boleh negatif
    if (proposedAdjustment < 0) {
      return;
    }
    setState(() {
      _stockAdjustment = proposedAdjustment;
      _stockAdjustmentController.text = _stockAdjustment.toString();
    });
  }

  // Helper untuk kembali ke mode display dan mereset state
  // Helper untuk mereset SEMUA controller saat batal
  void _switchToDisplayMode() {
    setState(() {
      _mode = DetailSheetMode.display;

      // Reset penyesuaian stok
      _stockAdjustment = 0;
      _stockAdjustmentController.text = '0';
      _adjustmentType = AdjustmentType.stockOut; // Reset ke default

      // Reset juga form detail ke nilai awal
      _nameController.text = widget.productName;
      _categoryController.text = widget.category;
      _capacityController.text = widget.capacity.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: ItemImage(imageUrl: imageUrl),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Gunakan Switch untuk menentukan body dan tombol
              ..._buildBodyAndButtons(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Method baru untuk memilih widget body dan tombol berdasarkan mode
  List<Widget> _buildBodyAndButtons() {
    switch (_mode) {
      case DetailSheetMode.adjustStock:
        return [
          _buildStockAdjustmentForm(),
          const SizedBox(height: 20),
          _buildStockAdjustmentButtons(),
        ];
      case DetailSheetMode.editForm:
        return [
          _buildFullEditForm(),
          const SizedBox(height: 20),
          _buildFullEditButtons(),
        ];
      case DetailSheetMode.display:
      default:
        return [
          _buildDisplayDetails(
            productName: widget.productName,
            category: widget.category,
            id: widget.id,
            stock: widget.stock,
            capacity: widget.capacity,
          ),
          const SizedBox(height: 20),
          _buildDisplayButtons(),
        ];
    }
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Pusatkan judul
      children: [
        Expanded(
          child: Text(
            widget.productName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              CupertinoIcons.clear_thick_circled,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayDetails({
    required String productName,
    required String category,
    required String id,
    required int stock,
    required int capacity,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(title: 'Barcode', value: id, icon: FontAwesomeIcons.barcode),
        _DetailRow(
          title: 'Nama Barang',
          value: productName,
          icon: CupertinoIcons.tag_fill, // Menggunakan ikon yang lebih relevan
        ),
        _DetailRow(
          title: 'Kategori',
          value: category,
          icon: FontAwesomeIcons.shapes,
        ),
        _DetailRow(
          title: 'Jumlah Barang',
          value: '$stock / $capacity',
          icon: FontAwesomeIcons.box, // Menggunakan ikon yang lebih relevan
        ),
      ],
    );
  }

  // 5. Tombol dipecah menjadi dua
  Widget _buildDisplayButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            child: const Text('Edit Detail'),
            onPressed: () => setState(() => _mode = DetailSheetMode.editForm),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            child: const Text('Sesuaikan Stok'),
            onPressed:
                () => setState(() => _mode = DetailSheetMode.adjustStock),
          ),
        ),
      ],
    );
  }

  // --- FORM KHUSUS UNTUK PENYESUAIAN STOK ---
  Widget _buildStockAdjustmentForm() {
    // --- PERUBAHAN 2: Logika kalkulasi stok baru dinamis ---
    int newStock =
        _adjustmentType == AdjustmentType.stockIn
            ? widget.stock + _stockAdjustment
            : widget.stock - _stockAdjustment;

    String title =
        _adjustmentType == AdjustmentType.stockIn
            ? "Penyesuaian Stok (Barang Masuk)"
            : "Penyesuaian Stok (Barang Keluar)";
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        // --- PERUBAHAN 3: Tambah ToggleButtons untuk memilih tipe ---
        ToggleButtons(
          isSelected: [
            _adjustmentType == AdjustmentType.stockOut,
            _adjustmentType == AdjustmentType.stockIn,
          ],
          onPressed: (index) {
            setState(() {
              _adjustmentType =
                  index == 0 ? AdjustmentType.stockOut : AdjustmentType.stockIn;
            });
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Theme.of(context).primaryColor,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Keluar'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Masuk'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStockAdjustmentRow(),
        const SizedBox(height: 16),
        Text(
          "Stok Saat Ini: ${widget.stock}",
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          "Stok Baru: $newStock",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color:
                _adjustmentType == AdjustmentType.stockIn
                    ? Colors.green
                    : Colors.orange,
          ),
        ),
      ],
    );
  }

  // Di dalam _BottomDetailProductState

  Widget _buildStockAdjustmentRow() {
    // Cek apakah stok bisa dikurangi lagi
    bool canDecrement = (widget.stock - _stockAdjustment) > 0;
    bool canIncrement =
        !(_adjustmentType == AdjustmentType.stockOut &&
            (widget.stock - _stockAdjustment) <= 0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tombol Kurang (-) akan nonaktif jika stok akan habis
        IconButton.outlined(
          icon: const Icon(FontAwesomeIcons.minus),
          // Gunakan null untuk menonaktifkan tombol
          onPressed: canIncrement ? () => _updateStockAdjustment(-1) : null,
        ),
        SizedBox(
          width: 80,
          child: TextFormField(
            controller: _stockAdjustmentController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onChanged: (value) {
              int newAdjustment = int.tryParse(value) ?? 0;

              // Validasi: Jika input manual akan membuat stok negatif,
              // batasi nilainya ke stok maksimum yang tersedia.
              if (widget.stock - newAdjustment < 0) {
                newAdjustment = widget.stock;
                _stockAdjustmentController.text = newAdjustment.toString();
                _stockAdjustmentController
                    .selection = TextSelection.fromPosition(
                  TextPosition(offset: _stockAdjustmentController.text.length),
                );
              }

              setState(() {
                _stockAdjustment = newAdjustment;
              });
            },
          ),
        ),
        // Tombol Tambah (+)
        IconButton.outlined(
          icon: const Icon(FontAwesomeIcons.plus),
          onPressed: canDecrement ? () => _updateStockAdjustment(1) : null,
        ),
      ],
    );
  }

  // Di dalam _BottomDetailProductState

  Widget _buildStockAdjustmentButtons() {
    // Tombol simpan hanya aktif jika ada perubahan
    bool isChanged = _stockAdjustment != 0;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            // Diubah ke OutlinedButton agar konsisten
            child: const Text('Batal'),
            onPressed: _switchToDisplayMode,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            child: const Text('Simpan Stok'),
            // Gunakan null untuk menonaktifkan tombol
            onPressed:
                isChanged
                    ? () {
                      // --- PERUBAHAN 4: Panggil callback yang sesuai ---
                      if (_adjustmentType == AdjustmentType.stockIn) {
                        widget.onStockIn?.call(widget.id, _stockAdjustment);
                      } else {
                        widget.onStockOut?.call(widget.id, _stockAdjustment);
                      }
                      Navigator.pop(context);
                    }
                    : null,
          ),
        ),
      ],
    );
  }

  // --- FORM UNTUK EDIT DETAIL PRODUK ---
  Widget _buildFullEditForm() {
    // Di sini nanti kita akan menggunakan semua TextEditingController
    return Column(
      children: [
        _InputForm(
          hintText: 'Barcode',
          initialValue: widget.id,
          enabled: false,
          prefixIcon: FontAwesomeIcons.barcode,
        ),
        const SizedBox(height: 10),
        _InputForm(
          hintText: 'Nama barang',
          initialValue: widget.productName,
          prefixIcon: CupertinoIcons.tag_fill,
        ),
        const SizedBox(height: 10),
        _InputForm(
          hintText: 'Kategori',
          initialValue: widget.category,
          prefixIcon: FontAwesomeIcons.shapes,
        ),
      ],
    );
  }

  Widget _buildFullEditButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            child: const Text('Batal'),
            onPressed: _switchToDisplayMode,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            child: const Text('Simpan Detail'),
            onPressed: () {
              // TODO: Panggil callback onDetailsSaved dengan data dari controller
              // final data = { 'name': _nameController.text, ... };
              // widget.onDetailsSaved?.call(data);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}

// Reusable Widget
// Widget untuk menampilkan detail dalam mode read-only
class _DetailRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable form input widget
// --- PERBARUI _InputForm untuk bisa menampilkan nilai awal ---
class _InputForm extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final String? initialValue; // Tambahkan ini
  final bool enabled; // Tambahkan ini
  final ValueChanged<String>? onChanged;

  const _InputForm({
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.initialValue, // Tambahkan ini
    this.enabled = true, // Tambahkan ini
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      initialValue: initialValue, // Gunakan ini
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(prefixIcon, size: 16, color: Colors.grey),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
      ),
    );
  }
}

// Reusable save button
class _SaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {},
        child: const Text(
          'Simpan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
