import 'package:flutter/material.dart';

class GameTheme {
  static const Color defaultBackgroundColor = Color(0xFF1E3A5F);
  static const String defaultLogoPath = 'assets/images/Logo.png';
  
  Color backgroundColor;
  String? backgroundImageAsset;
  String logoAsset;
  
  GameTheme({
    this.backgroundColor = defaultBackgroundColor,
    this.backgroundImageAsset,
    this.logoAsset = defaultLogoPath,
  });
  
  GameTheme copyWith({
    Color? backgroundColor,
    String? backgroundImageAsset,
    String? logoAsset,
  }) {
    return GameTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImageAsset: backgroundImageAsset ?? this.backgroundImageAsset,
      logoAsset: logoAsset ?? this.logoAsset,
    );
  }
  
  static GameTheme get defaultTheme => GameTheme();
}
