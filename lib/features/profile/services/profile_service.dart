import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../gifts/data/gifts_repository.dart';
import '../models/user_profile.dart';

class ProfileService {
  ProfileService({required this.giftsRepository});

  static const _keyProfile = 'user_profile_v1';
  final GiftsRepository giftsRepository;

  Future<UserProfile> getProfile({String fallbackName = 'Пользователь'}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProfile);
    if (raw == null) {
      final profile = UserProfile(id: _generateId(), nickname: fallbackName);
      await saveProfile(profile);
      return profile;
    }
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      final profile = UserProfile(id: _generateId(), nickname: fallbackName);
      await saveProfile(profile);
      return profile;
    }
  }

  Future<UserProfile> updateNickname(String nickname) async {
    final current = await getProfile();
    final updated = current.copyWith(nickname: nickname.trim());
    await saveProfile(updated);
    return updated;
  }

  Future<UserProfile> updateAvatar() async {
    final current = await getProfile();
    final url = await giftsRepository.imageService.nextImageUrl();
    final updated = current.copyWith(avatarUrl: url);
    await saveProfile(updated);
    return updated;
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  String _generateId() => 'user-${Random().nextInt(999999999)}';
}
