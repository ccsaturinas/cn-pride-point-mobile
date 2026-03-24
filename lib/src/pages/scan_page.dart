import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _handled = false;
  late final MobileScannerController _controller;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _controller.stop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Scan ID barcode')), //CODE39
        body: MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            if (_handled) return;
            final barcodes = capture.barcodes;
            for (final b in barcodes) {
              final v = b.rawValue;
              if (v == null || v.trim().isEmpty) continue;
              _handled = true;
              _controller.stop();
              Navigator.of(context).pop(v.trim());
              return;
            }
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(formats: [BarcodeFormat.code39]);
  }

  @override
  void deactivate() {
    _controller.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }
}
