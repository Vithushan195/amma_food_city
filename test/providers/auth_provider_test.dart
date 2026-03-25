import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amma_food_city/core/providers/auth_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier', () {
    test('starts unauthenticated', () {
      final auth = container.read(authProvider);
      expect(auth.isAuthenticated, false);
      expect(auth.isGuest, true);
      expect(auth.user, null);
      expect(auth.isLoading, false);
    });

    test('signInWithEmail succeeds with valid credentials', () async {
      final success = await container
          .read(authProvider.notifier)
          .signInWithEmail('test@test.com', 'password123');

      expect(success, true);
      expect(container.read(authProvider).isAuthenticated, true);
      expect(container.read(authProvider).user, isNotNull);
    });

    test('signInWithEmail fails with empty password', () async {
      final success = await container
          .read(authProvider.notifier)
          .signInWithEmail('test@test.com', '');

      expect(success, false);
      expect(container.read(authProvider).isAuthenticated, false);
      expect(container.read(authProvider).error, isNotNull);
    });

    test('signInWithEmail fails with short password', () async {
      final success = await container
          .read(authProvider.notifier)
          .signInWithEmail('test@test.com', '123');

      expect(success, false);
      expect(container.read(authProvider).error, isNotNull);
    });

    test('signUp creates user', () async {
      final success = await container.read(authProvider.notifier).signUp(
        name: 'Test User',
        email: 'new@test.com',
        password: 'password123',
      );

      expect(success, true);
      final auth = container.read(authProvider);
      expect(auth.isAuthenticated, true);
      expect(auth.user!.name, 'Test User');
      expect(auth.user!.email, 'new@test.com');
    });

    test('sendOtp succeeds', () async {
      final success = await container
          .read(authProvider.notifier)
          .sendOtp('07700900123');

      expect(success, true);
      expect(container.read(authProvider).isLoading, false);
    });

    test('verifyOtp succeeds with 6 digits', () async {
      final success = await container
          .read(authProvider.notifier)
          .verifyOtp('123456');

      expect(success, true);
      expect(container.read(authProvider).isAuthenticated, true);
    });

    test('verifyOtp fails with wrong length', () async {
      final success = await container
          .read(authProvider.notifier)
          .verifyOtp('12345');

      expect(success, false);
    });

    test('signOut clears user', () async {
      await container
          .read(authProvider.notifier)
          .signInWithEmail('test@test.com', 'password123');
      expect(container.read(authProvider).isAuthenticated, true);

      await container.read(authProvider.notifier).signOut();
      expect(container.read(authProvider).isAuthenticated, false);
      expect(container.read(authProvider).user, null);
    });

    test('clearError removes error state', () async {
      await container
          .read(authProvider.notifier)
          .signInWithEmail('test@test.com', '');
      expect(container.read(authProvider).error, isNotNull);

      container.read(authProvider.notifier).clearError();
      expect(container.read(authProvider).error, null);
    });

    test('isAuthenticatedProvider reflects state', () async {
      expect(container.read(isAuthenticatedProvider), false);

      await container
          .read(authProvider.notifier)
          .signInWithEmail('test@test.com', 'password123');
      expect(container.read(isAuthenticatedProvider), true);
    });

    test('currentUserProvider reflects state', () async {
      expect(container.read(currentUserProvider), null);

      await container
          .read(authProvider.notifier)
          .signInWithEmail('test@test.com', 'password123');
      expect(container.read(currentUserProvider), isNotNull);
    });
  });
}
