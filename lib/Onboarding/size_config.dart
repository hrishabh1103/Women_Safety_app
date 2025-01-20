import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;  // Use late for deferred initialization
  static double screenW = 0.0;  // Initialize with default values
  static double screenH = 0.0;
  static double blockH = 0.0;
  static double blockV = 0.0;

  // Initialize method to calculate screen dimensions and other properties
  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);  // Get MediaQueryData
    screenW = _mediaQueryData.size.width;  // Set screen width
    screenH = _mediaQueryData.size.height;  // Set screen height
    blockH = screenW / 100;  // Calculate horizontal block unit
    blockV = screenH / 100;  // Calculate vertical block unit
  }
}
