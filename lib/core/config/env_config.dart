/// Environment configuration for Amma Food City.
///
/// Switch environments by changing the [current] field.
/// In production, use --dart-define=ENV=production
enum Env { dev, staging, production }

class EnvConfig {
  static Env current = Env.dev;

  /// Initialize from dart-define or default to dev.
  static void init() {
    const envString = String.fromEnvironment('ENV', defaultValue: 'dev');
    current = switch (envString) {
      'production' || 'prod' => Env.production,
      'staging' || 'stg' => Env.staging,
      _ => Env.dev,
    };
  }

  // ── Firebase ──────────────────────────────────────────────
  static bool get useFirestoreEmulator => current == Env.dev;
  static bool get useFirestore => current != Env.dev;

  // ── Stripe ────────────────────────────────────────────────
  static String get stripePublishableKey => switch (current) {
    Env.production => const String.fromEnvironment(
      'STRIPE_PK',
      defaultValue: 'pk_live_YOUR_LIVE_KEY',
    ),
    _ => const String.fromEnvironment(
      'STRIPE_PK',
      defaultValue: 'pk_test_YOUR_TEST_KEY',
    ),
  };

  // ── API Base URLs ─────────────────────────────────────────
  static String get cloudFunctionsRegion => 'europe-west2';

  // ── Feature Flags ─────────────────────────────────────────
  static bool get enableDevTools => current != Env.production;
  static bool get enableMockData => current == Env.dev;
  static bool get enableCrashlytics => current == Env.production;
  static bool get enableAnalytics => current != Env.dev;

  // ── App Info ──────────────────────────────────────────────
  static String get appName => switch (current) {
    Env.production => 'Amma Food City',
    Env.staging => 'Amma Food City (STG)',
    Env.dev => 'Amma Food City (DEV)',
  };

  static String get envLabel => switch (current) {
    Env.production => 'Production',
    Env.staging => 'Staging',
    Env.dev => 'Development',
  };
}
