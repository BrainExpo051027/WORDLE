import 'package:flutter/material.dart';
import '../models/theme_model.dart';

class AppConfig {
  static GameTheme appTheme = GameTheme.defaultTheme;
  
  static void updateTheme(GameTheme newTheme) {
    appTheme = newTheme;
  }
  
  static void setBackgroundImage(String assetPath) {
    appTheme = appTheme.copyWith(backgroundImageAsset: assetPath);
  }
  
  static void setBackgroundColor(Color color) {
    appTheme = appTheme.copyWith(backgroundColor: color);
  }
  
  static void setLogoAsset(String assetPath) {
    appTheme = appTheme.copyWith(logoAsset: assetPath);
  }
}
