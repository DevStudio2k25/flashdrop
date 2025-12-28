import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_colors.dart';

/// QR Code scanner screen
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    // Allow any non-empty code
    if (_isScanned) return;

    setState(() => _isScanned = true);
    Navigator.pop(context, code);
  }

  // Helper removed as we accept raw token/JSON now
  // bool _isValidIP(String ip) { ... }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Scanner
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Overlay
          CustomPaint(painter: ScannerOverlayPainter(), child: Container()),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Point camera at QR code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'The IP address will be detected automatically',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Flash toggle
          Positioned(
            bottom: 32,
            right: 32,
            child: FloatingActionButton(
              onPressed: () => _controller.toggleTorch(),
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.flash_on, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for scanner overlay
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;

    // Draw overlay with transparent center
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
          const Radius.circular(20),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final bracketLength = 30.0;

    // Top-left
    canvas.drawLine(
      Offset(left, top + bracketLength),
      Offset(left, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + bracketLength, top),
      bracketPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(left + scanAreaSize - bracketLength, top),
      Offset(left + scanAreaSize, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + bracketLength),
      bracketPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(left, top + scanAreaSize - bracketLength),
      Offset(left, top + scanAreaSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + bracketLength, top + scanAreaSize),
      bracketPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(left + scanAreaSize - bracketLength, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - bracketLength),
      Offset(left + scanAreaSize, top + scanAreaSize),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
