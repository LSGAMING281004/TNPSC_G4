import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_user_model.dart';
import '../../core/constants/admin_constants.dart';

// ─── Auth State ───
enum AdminAuthStatus { initial, authenticated, unauthenticated, accessDenied }

class AdminAuthState {
  final AdminAuthStatus status;
  final AdminUserModel? user;
  final String? error;
  final bool isLoading;

  const AdminAuthState({
    this.status = AdminAuthStatus.initial,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AdminAuthState copyWith({
    AdminAuthStatus? status,
    AdminUserModel? user,
    String? error,
    bool? isLoading,
  }) {
    return AdminAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── Auth Notifier ───
class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminAuthNotifier({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const AdminAuthState()) {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        state = const AdminAuthState(status: AdminAuthStatus.unauthenticated);
      } else {
        await _loadAdminProfile(user.uid);
      }
    });
  }

  Future<void> _loadAdminProfile(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      final doc = await _firestore
          .collection(AdminConstants.adminUsersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        // Not an admin — sign out
        await _auth.signOut();
        state = const AdminAuthState(
          status: AdminAuthStatus.accessDenied,
          error: 'Access Denied: You are not an admin.',
        );
        return;
      }

      final admin = AdminUserModel.fromFirestore(doc);
      if (admin.role == AdminConstants.roleUser) {
        await _auth.signOut();
        state = const AdminAuthState(
          status: AdminAuthStatus.accessDenied,
          error: 'Access Denied: Insufficient permissions.',
        );
        return;
      }

      // Update last login
      await _firestore
          .collection(AdminConstants.adminUsersCollection)
          .doc(uid)
          .update({'lastLoginAt': FieldValue.serverTimestamp()});

      state = AdminAuthState(
        status: AdminAuthStatus.authenticated,
        user: admin,
      );
    } catch (e) {
      state = AdminAuthState(
        status: AdminAuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Auth state listener handles the rest
    } on FirebaseAuthException catch (e) {
      state = AdminAuthState(
        status: AdminAuthStatus.unauthenticated,
        error: _mapAuthError(e.code),
        isLoading: false,
      );
    } catch (e) {
      state = AdminAuthState(
        status: AdminAuthStatus.unauthenticated,
        error: 'Login failed: $e',
        isLoading: false,
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AdminAuthState(status: AdminAuthStatus.unauthenticated);
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No admin account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'invalid-credential':
        return 'Invalid credentials. Check email and password.';
      default:
        return 'Authentication error: $code';
    }
  }
}

// ─── Providers ───
final adminAuthProvider =
    StateNotifierProvider<AdminAuthNotifier, AdminAuthState>(
  (ref) => AdminAuthNotifier(),
);

final currentAdminProvider = Provider<AdminUserModel?>((ref) {
  return ref.watch(adminAuthProvider).user;
});

final isAdminAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(adminAuthProvider).status == AdminAuthStatus.authenticated;
});
