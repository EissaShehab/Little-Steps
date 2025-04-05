import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:littlesteps/features/auth/data/auth_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  factory AuthState.initial() => AuthState(user: null, isLoading: false, error: null);

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  late final StreamSubscription<User?> _authSubscription;

  AuthNotifier(this._authService) : super(AuthState.initial()) {
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (state.user != user) {
        state = state.copyWith(user: user, error: null);
      }
    }, onError: (error) {
      state = state.copyWith(error: error.toString());
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _authService.logout();
      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _authService.changePassword(currentPassword, newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});