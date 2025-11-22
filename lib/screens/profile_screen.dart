import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/profile/bloc/profile_cubit.dart';
import '../features/profile/bloc/profile_state.dart';
import '../features/theme/bloc/theme_cubit.dart';
import '../features/theme/bloc/theme_state.dart';
import '../navigation/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: const Text('Отмена')),
          FilledButton(onPressed: () => ctx.pop(true), child: const Text('Выйти')),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed == true) {
      context.read<AuthBloc>().add(const LogoutRequested());
      context.go(AppRoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final isEditing = state is ProfileLoaded && state.isEditing;
              return IconButton(
                tooltip: isEditing ? 'Сохранить' : 'Редактировать',
                icon: Icon(isEditing ? Icons.check : Icons.edit_outlined),
                onPressed: () {
                  if (state is! ProfileLoaded) return;
                  if (isEditing) {
                    context.read<ProfileCubit>().updateNickname(_nicknameController.text);
                  } else {
                    _nicknameController.text = state.profile.nickname;
                    context.read<ProfileCubit>().startEditing();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileError && state.profile == null) {
              return Center(child: Text(state.message));
            }
            final profileState = state is ProfileLoaded
                ? state
                : (state is ProfileError && state.profile != null)
                    ? ProfileLoaded(state.profile!)
                    : null;

            if (profileState == null) {
              return const SizedBox.shrink();
            }

            final profile = profileState.profile;
            final isEditing = profileState.isEditing;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage:
                            profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                        child:
                            profile.avatarUrl == null ? const Icon(Icons.person_outline, size: 48) : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          onPressed: () => context.read<ProfileCubit>().changeAvatar(),
                          icon: const Icon(Icons.camera_alt_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    profile.nickname,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Center(
                  child: Text(
                    'ID: ${profile.id}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                if (isEditing)
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(labelText: 'Никнейм'),
                  ),
                const SizedBox(height: 16),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, themeState) {
                    final isDark =
                        themeState is ThemeLoaded ? themeState.themeMode == ThemeMode.dark : false;
                    return SwitchListTile(
                      title: const Text('Тёмная тема'),
                      subtitle: Text(isDark ? 'Включена' : 'Выключена'),
                      value: isDark,
                      onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('О приложении'),
                        SizedBox(height: 8),
                        Text('• Изображения кэшируются автоматически'),
                        Text('• Работает с интернетом и без него'),
                        Text('• Случайные изображения от Picsum Photos'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Выйти из аккаунта'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
