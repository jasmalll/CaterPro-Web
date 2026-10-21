import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// App-wide theme preference persisted locally in Hive.
class CaterProThemeController extends ChangeNotifier {
  static const _boxName = 'settings_box';
  static const _key = 'dark_mode';
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final box = await Hive.openBox(_boxName);
    _isDark = box.get(_key, defaultValue: false) == true;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    final box = await Hive.openBox(_boxName);
    await box.put(_key, _isDark);
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    final box = await Hive.openBox(_boxName);
    await box.put(_key, value);
    notifyListeners();
  }
}
