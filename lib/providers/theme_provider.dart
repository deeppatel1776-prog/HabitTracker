import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/local_storage_service.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorageService _localStorage = LocalStorageService();

  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() async {
    final index = await _localStorage.getThemeModeIndex();
    if (index == 1) {
      state = ThemeMode.dark;
    } else if (index == 2) {
      state = ThemeMode.system;
    } else {
      state = ThemeMode.light;
    }
  }

  void setThemeMode(ThemeMode mode) async {
    state = mode;
    int index = 0;
    if (mode == ThemeMode.dark) index = 1;
    if (mode == ThemeMode.system) index = 2;
    await _localStorage.setThemeModeIndex(index);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
