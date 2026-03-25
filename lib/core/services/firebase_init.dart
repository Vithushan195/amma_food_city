import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase initialization helper.
/// Call FirebaseInit.initialize() in main() before runApp().
class FirebaseInit {
  FirebaseInit._();

  static bool _initialized = false;

  /// Initialize Firebase and configure Firestore settings.
  /// Pass your firebase_options.dart DefaultFirebaseOptions.
  static Future<void> initialize({
    FirebaseOptions? options,
    bool useEmulator = false,
  }) async {
    if (_initialized) return;

    await Firebase.initializeApp(options: options);

    // Configure Firestore
    final firestore = FirebaseFirestore.instance;

    // Enable offline persistence (default on mobile, explicit for web)
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Use emulator in development
    if (useEmulator) {
      firestore.useFirestoreEmulator('localhost', 8080);
    }

    _initialized = true;
  }
}
