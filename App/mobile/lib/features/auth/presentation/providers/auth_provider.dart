import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahalle_connect/data/models/user.dart';
import 'package:mahalle_connect/features/auth/data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserResponse? user;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserResponse? user,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final loggedIn = await _repo.isLoggedIn();
    if (loggedIn) {
      try {
        final user = await _repo.getProfile();
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } catch (_) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.login(email: email, password: password);
      final user = await _repo.getProfile();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      String message = 'Login failed';
      if (e.toString().contains('401')) {
        message = 'Invalid email or password';
      } else if (e.toString().contains('423')) {
        message = 'Account temporarily locked';
      }
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  Future<void> register(String email, String password, String fullName, String? username) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.register(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
      );
      final user = await _repo.getProfile();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      String message = 'Registration failed';
      if (e.toString().contains('409')) {
        message = 'Email or username already taken';
      }
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
