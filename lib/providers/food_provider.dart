import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/food_item.dart';

class FoodProvider with ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'http://localhost:8000'),
  ); // Use actual IP for physical device

  List<FoodItem> _history = [];
  List<FoodItem> get history => _history;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  Future<FoodItem?> scanBarcode(String upc) async {
    _isScanning = true;
    notifyListeners();

    try {
      final response = await _dio.post(
        '/scan/barcode',
        data: FormData.fromMap({'upc': upc}),
      );
      if (response.data['status'] == 'success') {
        final item = FoodItem.fromJson(response.data['data']);
        return item;
      }
    } catch (e) {
      debugPrint('Barcode scan error: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
    return null;
  }

  Future<FoodItem?> scanImage(File imageFile) async {
    _isScanning = true;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post('/scan/image', data: formData);
      if (response.data['status'] == 'success') {
        final item = FoodItem.fromJson(response.data['data']);
        return item;
      }
    } catch (e) {
      debugPrint('Image scan error: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
    return null;
  }

  void logFood(FoodItem item) {
    _history.insert(0, item);
    notifyListeners();
  }
}
