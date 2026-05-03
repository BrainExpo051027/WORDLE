# 🎨 Customization Guide: Backgrounds & Logos

This guide explains how to customize the background images and logos in your Wordle game.

---

## 📁 Directory Structure

```
project/
├── lib/
│   ├── config/
│   │   └── app_config.dart          ← Main configuration file
│   ├── models/
│   │   └── theme_model.dart         ← Theme settings
│   └── screens/
│       ├── loading_screen.dart      ← Uses logo
│       ├── menu_screen.dart         ← Uses background
│       └── enhanced_game_screen.dart ← Uses background
└── assets/
    └── images/
        ├── background.png           ← Your custom background
        ├── logo.png                 ← Your custom logo
        └── README.md (this file)
```

---

## 🖼️ How to Change Background Image

### Step 1: Prepare Your Image
- **Recommended size:** 1080x1920 pixels (9:16 aspect ratio)
- **Formats supported:** PNG, JPG, JPEG
- **File name:** `background.png` or `background.jpg`

### Step 2: Add Image to Project
1. Place your image file in: `assets/images/`
2. Make sure the filename is `background.png` (or `.jpg`)

### Step 3: Update `pubspec.yaml`
Open `pubspec.yaml` and ensure this section exists:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

### Step 4: Update Configuration
Open `lib/config/app_config.dart` and modify:

```dart
class AppConfig {
  // Change the path to your background image
  static void setBackgroundImage(String assetPath) {
    _currentTheme.backgroundImageAsset = assetPath;
  }
}
```

### Step 5: Apply in Your Screens
In `lib/screens/enhanced_game_screen.dart` or `menu_screen.dart`:

```dart
@override
void initState() {
  super.initState();
  // Set your custom background
  AppConfig.setBackgroundImage('assets/images/background.png');
}
```

### Default Usage (Already Implemented)
The theme already supports background images via `GameTheme.defaultTheme`. Simply add your image file and it will be used automatically if the path is set.

---

## 🏆 How to Change Logo

### Step 1: Prepare Your Logo
- **Recommended size:** 512x512 pixels (square)
- **Formats supported:** PNG (with transparency recommended)
- **File name:** `logo.png`

### Step 2: Add Logo to Project
1. Place your logo file in: `assets/images/`
2. Make sure the filename is `logo.png`

### Step 3: Update `pubspec.yaml`
Ensure the assets section includes:

```yaml
flutter:
  assets:
    - assets/images/logo.png
```

### Step 4: Update Loading Screen
Open `lib/screens/loading_screen.dart` and modify:

```dart
LoadingScreen({
  super.key,
  this.customLogoAsset = 'assets/images/logo.png', // Your logo path
})
```

Or use the AppConfig:

```dart
AppConfig.setLogo('assets/images/logo.png');
```

---

## 🎨 Using Solid Colors Instead of Images

If you prefer solid colors over images:

### For Background Color:
```dart
AppConfig.setBackgroundColor(const Color(0xFF1E3A5F));
```

### Remove Background Image:
```dart
AppConfig.setBackgroundImage(null);
```

---

## 🔧 Advanced Customization

### Custom Theme Configuration

Edit `lib/models/theme_model.dart`:

```dart
class GameTheme {
  Color backgroundColor;
  String? backgroundImageAsset;
  String? logoAsset;

  GameTheme({
    required this.backgroundColor,
    this.backgroundImageAsset,
    this.logoAsset,
  });

  static GameTheme defaultTheme = GameTheme(
    backgroundColor: const Color(0xFF1E3A5F),  // Dark blue
    backgroundImageAsset: 'assets/images/background.png',
    logoAsset: 'assets/images/logo.png',
  );
}
```

### Changing Opacity
In the screen widgets, you can adjust the image opacity:

```dart
DecorationImage(
  image: AssetImage(_theme.backgroundImageAsset!),
  fit: BoxFit.cover,
  opacity: 0.8,  // Change this value (0.0 to 1.0)
)
```
