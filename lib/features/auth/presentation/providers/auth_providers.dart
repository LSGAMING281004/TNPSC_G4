import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../data/repositories/auth_repository.dart';

// ─── Auth Repository Provider ───
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// ─── Auth State ───
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({bool? isLoading, bool? isAuthenticated, UserModel? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }

  factory AuthState.initial() => const AuthState();
  factory AuthState.loading() => const AuthState(isLoading: true);
  factory AuthState.authenticated(UserModel user) => AuthState(isAuthenticated: true, user: user);
  factory AuthState.unauthenticated() => const AuthState(isAuthenticated: false);
  factory AuthState.error(String message) => AuthState(error: message);
}

// ─── Auth Notifier ───
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(AuthState.initial());

  Future<void> signInWithEmail({required String email, required String password}) async {
    state = AuthState.loading();
    try {
      final user = await _repository.signInWithEmail(email: email, password: password);
      _ref.read(currentUserProvider.notifier).state = user;
      state = AuthState.authenticated(user);
    } catch (e, stack) {
      debugPrint('signInWithEmail error: $e\n$stack');
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmail({
    required String name, required String email, required String password,
    String district = '', int targetScore = 150,
  }) async {
    state = AuthState.loading();
    try {
      final user = await _repository.signUpWithEmail(
        name: name, email: email, password: password,
        district: district, targetScore: targetScore,
      );
      _ref.read(currentUserProvider.notifier).state = user;
      state = AuthState.authenticated(user);
    } catch (e, stack) {
      debugPrint('signUpWithEmail error: $e\n$stack');
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = AuthState.loading();
    try {
      final user = await _repository.signInWithGoogle();
      _ref.read(currentUserProvider.notifier).state = user;
      state = AuthState.authenticated(user);
    } catch (e, stack) {
      debugPrint('signInWithGoogle error: $e\n$stack');
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInAsGuest() async {
    state = AuthState.loading();
    try {
      final user = await _repository.signInAsGuest();
      _ref.read(currentUserProvider.notifier).state = user;
      state = AuthState.authenticated(user);
    } catch (e, stack) {
      debugPrint('signInAsGuest error: $e\n$stack');
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _ref.read(currentUserProvider.notifier).state = null;
    state = AuthState.unauthenticated();
  }

  Future<void> resetPassword({required String email}) async {
    state = AuthState.loading();
    try {
      await _repository.resetPassword(email: email);
      state = AuthState.initial();
    } catch (e, stack) {
      debugPrint('resetPassword error: $e\n$stack');
      state = AuthState.error(e.toString());
    }
  }

  Future<void> checkCurrentUser() async {
    final user = await _repository.getCurrentUser();
    if (user != null) {
      _ref.read(currentUserProvider.notifier).state = user;
      state = AuthState.authenticated(user);
    } else {
      state = AuthState.unauthenticated();
    }
  }
}

// ─── Auth Notifier Provider ───
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});
