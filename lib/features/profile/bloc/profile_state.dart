import 'package:equatable/equatable.dart';

import '../models/user_profile.dart';


abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final bool isEditing;

  const ProfileLoaded(this.profile, {this.isEditing = false});

  ProfileLoaded copyWith({
    UserProfile? profile,
    bool? isEditing,
  }) {
    return ProfileLoaded(
      profile ?? this.profile,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [profile, isEditing];
}

class ProfileUpdating extends ProfileState {
  final UserProfile profile;
  const ProfileUpdating(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;
  final UserProfile? profile;
  const ProfileError(this.message, {this.profile});

  @override
  List<Object?> get props => [message, profile];
}
