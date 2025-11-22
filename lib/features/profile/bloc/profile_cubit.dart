import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/logger_service.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import 'profile_state.dart';


class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService;

  ProfileCubit({required ProfileService profileService})
      : _profileService = profileService,
        super(const ProfileInitial());

  Future<void> loadProfile({String fallbackName = 'WishlistUser'}) async {
    emit(const ProfileLoading());
    try {
      final profile = await _profileService.getProfile(fallbackName: fallbackName);
      emit(ProfileLoaded(profile));
      LoggerService.info('ProfileCubit: загрузили ${profile.nickname}');
    } catch (e) {
      emit(ProfileError('Не удалось загрузить профиль: $e'));
    }
  }

  Future<void> updateNickname(String nickname) async {
    if (nickname.trim().isEmpty) {
      emit(ProfileError('Никнейм не может быть пустым', profile: _currentProfile));
      emit(ProfileLoaded(_currentProfile ?? UserProfile(id: 'temp', nickname: 'User')));
      return;
    }
    emit(ProfileUpdating(_currentProfile ?? UserProfile(id: 'temp', nickname: 'User')));
    try {
      final updated = await _profileService.updateNickname(nickname);
      emit(ProfileLoaded(updated, isEditing: false));
    } catch (e) {
      emit(ProfileError('Ошибка сохранения: $e', profile: _currentProfile));
    }
  }

  Future<void> changeAvatar() async {
    emit(ProfileUpdating(_currentProfile ?? UserProfile(id: 'temp', nickname: 'User')));
    try {
      final updated = await _profileService.updateAvatar();
      emit(ProfileLoaded(updated, isEditing: state is ProfileLoaded && (state as ProfileLoaded).isEditing));
    } catch (e) {
      emit(ProfileError('Ошибка смены аватара: $e', profile: _currentProfile));
    }
  }

  void startEditing() {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(isEditing: true));
    }
  }

  void cancelEditing() {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(isEditing: false));
    }
  }

  UserProfile? get _currentProfile =>
      state is ProfileLoaded ? (state as ProfileLoaded).profile : null;
}
