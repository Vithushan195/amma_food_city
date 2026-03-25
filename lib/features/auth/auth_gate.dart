import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/providers/providers.dart';
import '../../core/services/fcm_service.dart';
import '../splash/splash_screen.dart';
import '../onboarding/onboarding_screen.dart';
import 'login_screen.dart';
import '../app_shell.dart';

enum _AppState { splash, onboarding, login, home }

/// AuthGate — root navigator controlling:
/// Splash → Onboarding (first launch) → Login → Home
///
/// FCM token is saved to Firestore on every successful login,
/// and cleared on sign-out.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});
  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  _AppState _state = _AppState.splash;
  bool _onboardingDone = false;
  bool _guestMode = false;
  int _lastSignOutCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOnboardingFlag();
  }

  Future<void> _loadOnboardingFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _onboardingDone = prefs.getBool('onboarding_complete') ?? false;
    } catch (_) {
      _onboardingDone = false;
    }
  }

  void _onSplashDone() {
    setState(() {
      if (!_onboardingDone) {
        _state = _AppState.onboarding;
      } else if (ref.read(authProvider).isAuthenticated) {
        // Already logged in — save FCM token and go home
        _saveFcmToken();
        _state = _AppState.home;
      } else {
        _state = _AppState.login;
      }
    });
  }

  void _onOnboardingDone() {
    setState(() {
      _onboardingDone = true;
      _state = _AppState.login;
    });
  }

  void _onAuthResult(bool? result) {
    if (result == null) return; // cancelled, stay on login
    setState(() {
      if (result) {
        // Authenticated via email/phone/signup — save FCM token
        _guestMode = false;
        _saveFcmToken();
      } else {
        // Guest mode
        _guestMode = true;
      }
      _state = _AppState.home;
    });
  }

  /// Writes the current FCM token to users/{uid}.fcmToken
  void _saveFcmToken() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FcmService.instance.saveTokenForUser(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for sign-out trigger from Profile
    final signOutCount = ref.watch(signOutTriggerProvider);
    if (signOutCount > _lastSignOutCount && _state == _AppState.home) {
      _lastSignOutCount = signOutCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _guestMode = false;
          _state = _AppState.login;
        });
      });
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _buildScreen(),
    );
  }

  Widget _buildScreen() {
    switch (_state) {
      case _AppState.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onComplete: _onSplashDone,
        );
      case _AppState.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          onComplete: _onOnboardingDone,
        );
      case _AppState.login:
        return LoginScreen(
          key: const ValueKey('login'),
          onAuthResult: _onAuthResult,
        );
      case _AppState.home:
        return const AppShell(key: ValueKey('home'));
    }
  }
}
