import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String nickname;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.nickname,
    this.avatarUrl,
  });

  UserProfile copyWith({
    String? id,
    String? nickname,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'avatarUrl': avatarUrl,
      };

  static UserProfile fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        nickname: json['nickname'] as String? ?? 'User',
        avatarUrl: json['avatarUrl'] as String?,
      );

  @override
  List<Object?> get props => [id, nickname, avatarUrl];
}
