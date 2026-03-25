import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// Auth state — holds current user or null if not authenticated.
class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  bool get isGuest => !isAuthenticated;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Sign in with email/password.
  /// In production: FirebaseAuth.signInWithEmailAndPassword
  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock validation
      if (email.isEmpty || password.length < 6) {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid credentials',
        );
        return false;
      }

      state = AuthState(user: AppUser.mockUser);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Send OTP to phone number.
  /// In production: FirebaseAuth.verifyPhoneNumber
  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Verify OTP and sign in.
  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (otp.length != 6) {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid OTP',
        );
        return false;
      }
      state = AuthState(user: AppUser.mockUser);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Sign up with email/password.
  /// In production: FirebaseAuth.createUserWithEmailAndPassword + Firestore doc
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = AuthState(
        user: AppUser(
          uid: 'new_user_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email,
          createdAt: DateTime.now(),
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Sign out.
  /// In production: FirebaseAuth.signOut
  Future<void> signOut() async {
    state = const AuthState();
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Global auth provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience: is user authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Convenience: current user (nullable).
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).user;
});

/// Flag that triggers when user explicitly signs out.
/// AuthGate watches this to exit guest mode and return to login.
final signOutTriggerProvider = StateProvider<int>((ref) => 0);
