import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_routes.dart';
import '../profile/bloc/profile_cubit.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'student');
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(bool isLogin) {
    if (!_formKey.currentState!.validate()) return;
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final bloc = context.read<AuthBloc>();
    if (isLogin) {
      bloc.add(LoginRequested(username, password));
    } else {
      bloc.add(RegisterRequested(username, password));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<ProfileCubit>().loadProfile(fallbackName: state.username);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Добро пожаловать, ${state.username}!')),
            );
            context.go(AppRoutePaths.home);
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthChecking) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final isLoading = state is AuthLoading;
                    bool isLogin;
                    if (state is AuthLoading) {
                      isLogin = state.isLogin;
                    } else if (state is AuthFailure) {
                      isLogin = state.isLogin;
                    } else if (state is AuthRegister) {
                      isLogin = false;
                    } else {
                      isLogin = true;
                    }
                    final title = isLogin ? 'Вход' : 'Регистрация';
                    final subtitle = isLogin
                        ? 'Войдите в свой аккаунт'
                        : 'Создайте новый аккаунт';

                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _usernameController,
                            enabled: !isLoading,
                            decoration: const InputDecoration(
                              labelText: 'Имя пользователя',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Укажите имя' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            enabled: !isLoading,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.length < 4) ? 'Минимум 4 символа' : null,
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: isLoading ? null : () => _submit(isLogin),
                            icon: Icon(isLogin ? Icons.login : Icons.person_add_alt),
                            label: Text(isLogin ? 'Войти' : 'Зарегистрироваться'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.read<AuthBloc>().add(const ToggleAuthMode()),
                            child: Text(
                              isLogin
                                  ? 'Нет аккаунта? Зарегистрируйтесь'
                                  : 'Уже есть аккаунт? Войдите',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
