import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/logger_service.dart';
import 'theme_state.dart';


class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(const ThemeInitial());

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      final themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      emit(ThemeLoaded(themeMode));
      LoggerService.info('Тема загружена: ${isDark ? "темная" : "светлая"}');
    } catch (e) {
      LoggerService.error('Ошибка загрузки темы: $e');
      emit(const ThemeLoaded(ThemeMode.light));
    }
  }

  Future<void> toggleTheme() async {
    try {
      if (state is! ThemeLoaded) return;
      final current = state as ThemeLoaded;
      final newTheme = current.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, newTheme == ThemeMode.dark);
      emit(ThemeLoaded(newTheme));
      LoggerService.info('Тема переключена на: ${newTheme == ThemeMode.dark ? "тёмную" : "светлую"}');
    } catch (e) {
      LoggerService.error('Ошибка переключения темы: $e');
    }
  }
}
