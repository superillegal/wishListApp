import 'dart:convert';
import 'dart:math';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ImageService {
  ImageService._();

  static final ImageService instance = ImageService._();

  static const _keyAvailableImages = 'image_pool_available';
  static const _keyUsedImages = 'image_pool_used';
  static const int _imagePoolSize = 20;

  final CacheManager _cacheManager = DefaultCacheManager();

  final List<String> _availableImages = [];
  final Set<String> _usedImages = <String>{};

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _restoreState();

    if (_availableImages.isEmpty) {
      await _generateImagePool();
    }

    _isInitialized = true;
  }

  Future<void> preloadImagePool() async {
    await initialize();
    await _preloadUrls(_availableImages);
  }

  Future<String> nextImageUrl() async {
    await initialize();
    if (_availableImages.isEmpty) {
      await _generateImagePool();
      await _preloadUrls(_availableImages);
    }
    final url = _availableImages.removeAt(0);
    _usedImages.add(url);
    await _saveState();
    return url;
  }

  Future<void> _restoreState() async {
    final availableJson = _prefs?.getString(_keyAvailableImages);
    final usedJson = _prefs?.getString(_keyUsedImages);

    if (availableJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(availableJson) as List<dynamic>;
        _availableImages
          ..clear()
          ..addAll(decoded.cast<String>());
      } catch (_) {
        _availableImages.clear();
      }
    }

    if (usedJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(usedJson) as List<dynamic>;
        _usedImages
          ..clear()
          ..addAll(decoded.cast<String>());
      } catch (_) {
        _usedImages.clear();
      }
    }
  }

  Future<void> _generateImagePool() async {
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    _availableImages.clear();
    while (_availableImages.length < _imagePoolSize) {
      final url = _buildImageUrl(random);
      if (_availableImages.contains(url) || _usedImages.contains(url)) continue;
      _availableImages.add(url);
    }
    await _saveState();
  }

  String _buildImageUrl(Random random) {
    final seed = DateTime.now().millisecondsSinceEpoch + random.nextInt(1 << 20);
    return 'https://picsum.photos/seed/$seed/400/600';
  }

  Future<void> _preloadUrls(List<String> urls) async {
    for (final url in urls) {
      try {
        await _cacheManager.downloadFile(url);
        print('Прездагружено изображение подарка $url');
      } catch (e) {
        print('Ошибка предзагрузки $url: $e');
      }
    }
  }

  Future<void> _saveState() async {
    await _prefs?.setString(_keyAvailableImages, jsonEncode(_availableImages));
    await _prefs?.setString(_keyUsedImages, jsonEncode(_usedImages.toList()));
  }
}
