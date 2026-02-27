import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../models/food_item.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isProcessing = false;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      _controller!.startImageStream(_processCameraImage);
      setState(() {
        _isCameraReady = true;
      });
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final upc = barcodes.first.rawValue;
        if (upc != null) {
          _controller?.stopImageStream();
          _handleBarcodeFound(upc);
        }
      }
    } catch (e) {
      debugPrint('Processing error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  InputImage _inputImageFromCameraImage(CameraImage image) {
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg, // Assume default for now
      format: InputImageFormat.bgra8888, // Common format
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  void _handleBarcodeFound(String upc) async {
    final provider = context.read<FoodProvider>();
    final item = await provider.scanBarcode(upc);
    if (item != null) {
      _showFoodResult(item);
    } else {
      // Barcode not in database, fallback to image
      _captureAndAnalyze();
    }
  }

  void _captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final image = await _controller!.takePicture();
    final provider = context.read<FoodProvider>();
    final item = await provider.scanImage(File(image.path));

    if (item != null) {
      _showFoodResult(item);
    }
  }

  void _showFoodResult(FoodItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FoodResultSheet(item: item),
    ).then((_) {
      if (mounted) {
        _controller?.startImageStream(_processCameraImage);
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [CameraPreview(_controller!), _buildOverlay()]),
    );
  }

  Widget _buildOverlay() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text(
                  'Scanner',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: ElevatedButton.icon(
              onPressed: _captureAndAnalyze,
              icon: const Icon(Icons.camera),
              label: const Text('Analyze Image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodResultSheet extends StatelessWidget {
  final FoodItem item;
  const _FoodResultSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
          if (item.brand != null) Text(item.brand!),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroInfo('Calories', '${item.calories}', Colors.orange),
              _buildMacroInfo('Protein', '${item.protein}g', Colors.red),
              _buildMacroInfo('Carbs', '${item.carbs}g', Colors.blue),
              _buildMacroInfo('Fat', '${item.fat}g', Colors.yellow),
            ],
          ),
          const SizedBox(height: 24),
          if (item.explanation != null) ...[
            Text(
              'Why this result?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(item.explanation!),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                context.read<FoodProvider>().logFood(item);
                Navigator.pop(context); // Close sheet
                Navigator.pop(context); // Back to dashboard
              },
              child: const Text('Log Food'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
