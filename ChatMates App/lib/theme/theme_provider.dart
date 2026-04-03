import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomFontColor { gold, white, pink, yellow }
enum CustomFontFamily { roboto, lobster, montserrat }

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  CustomFontColor _fontColor = CustomFontColor.white;
  CustomFontFamily _fontFamily = CustomFontFamily.roboto;

  bool get isDarkMode => _isDarkMode;
  CustomFontColor get fontColor => _fontColor;
  CustomFontFamily get fontFamily => _fontFamily;

  ThemeProvider() {
    _loadPreferences();
  }

  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    _savePreferences();
    notifyListeners();
  }

  void setFontColor(CustomFontColor color) {
    _fontColor = color;
    _savePreferences();
    notifyListeners();
  }

  void setFontFamily(CustomFontFamily family) {
    _fontFamily = family;
    _savePreferences();
    notifyListeners();
  }

  Color getPrimaryTextColor() {
    switch (_fontColor) {
      case CustomFontColor.gold:
        return const Color(0xFFFFD700);
      case CustomFontColor.pink:
        return Colors.pinkAccent;
      case CustomFontColor.yellow:
        return Colors.yellow;
      case CustomFontColor.white:
      default:
        return _isDarkMode ? Colors.white : Colors.black87;
    }
  }

  TextTheme _getTextTheme() {
    final baseTheme = _isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final color = getPrimaryTextColor();

    TextTheme appliedTheme;
    switch (_fontFamily) {
      case CustomFontFamily.lobster:
        appliedTheme = GoogleFonts.lobsterTextTheme(baseTheme);
        break;
      case CustomFontFamily.montserrat:
        appliedTheme = GoogleFonts.montserratTextTheme(baseTheme);
        break;
      case CustomFontFamily.roboto:
      default:
        appliedTheme = GoogleFonts.robotoTextTheme(baseTheme);
        break;
    }

    return appliedTheme.apply(
      bodyColor: color,
      displayColor: color,
    );
  }

  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue,
        foregroundColor: _isDarkMode ? Colors.white : Colors.white,
        elevation: 0,
      ),
      textTheme: _getTextTheme(),
    );
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    final colorStr = prefs.getString('fontColor') ?? 'white';
    final familyStr = prefs.getString('fontFamily') ?? 'roboto';
    
    _fontColor = CustomFontColor.values.firstWhere(
      (e) => e.name == colorStr, 
      orElse: () => CustomFontColor.white
    );

    _fontFamily = CustomFontFamily.values.firstWhere(
      (e) => e.name == familyStr, 
      orElse: () => CustomFontFamily.roboto
    );

    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    prefs.setString('fontColor', _fontColor.name);
    prefs.setString('fontFamily', _fontFamily.name);
  }
}
