import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanBarcode extends StatefulWidget {
  const ScanBarcode({super.key});
  @override
  State<ScanBarcode> createState() => _ScanBarcodeState();
}

class _ScanBarcodeState extends State<ScanBarcode> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isFlashOn = false;
  bool _isCameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
      });
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Izin Kamera Dibutuhkan'),
            content: const Text(
              'Aplikasi ini memerlukan akses kamera untuk memindai barcode.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Oke'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: const Text('Buka Pengaturan'),
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted) {
      return const Scaffold(
        body: Center(child: Text('Meminta izin kamera...')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () async {
          _controller.stop();
          return true;
        },
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (barcode) {
                if (barcode.barcodes.isNotEmpty) {
                  final String? result = barcode.barcodes.first.displayValue;
                  if (result != null) {
                    // Berhenti memindai dan langsung kembali ke layar sebelumnya dengan data barcode
                    _controller.stop();
                    Navigator.pop(context, result);
                  }
                }
              },
            ),
            _buildOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Column(
      children: [
        _CustomAppBar(
          onBack: () => Navigator.pop(context),
          onFlashToggle: () {
            setState(() {
              _isFlashOn = !_isFlashOn;
            });
            _controller.toggleTorch();
          },
          isFlashOn: _isFlashOn,
        ),
        Expanded(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 50),
          child: Text(
            'Pindai barcode di dalam bingkai',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onFlashToggle;
  final bool isFlashOn;

  const _CustomAppBar({
    required this.onBack,
    required this.onFlashToggle,
    required this.isFlashOn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
          ),
          IconButton(
            onPressed: onFlashToggle,
            icon: Icon(
              isFlashOn ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt,
              color: isFlashOn ? Colors.yellow : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
