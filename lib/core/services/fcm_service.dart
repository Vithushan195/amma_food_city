import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles FCM token storage + push notification display for the customer app.
///
/// Call [initialize] once after Firebase is initialized (in main.dart or AuthGate).
/// Call [saveTokenForUser] after login to write the token to Firestore.
/// Call [clearToken] on sign-out so the user stops receiving pushes.
class FcmService {
  FcmService._();
  static final instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  String? _token;
  String? get token => _token;

  bool _initialized = false;

  // ── Android notification channel ──────────────────────
  static const _channel = AndroidNotificationChannel(
    'order_updates', // id
    'Order Updates', // name
    description: 'Notifications about your order status',
    importance: Importance.high,
    playSound: true,
  );

  /// Step 1: Call this once at app startup (after Firebase.initializeApp).
  /// Requests permission, gets initial token, sets up foreground handler.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Request permission (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      debugPrint('FCM: User declined notification permission');
      return;
    }

    // Get initial token
    _token = await _messaging.getToken();
    debugPrint('FCM token: $_token');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _token = newToken;
      debugPrint('FCM token refreshed: $newToken');
      // Re-save if user is logged in
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        _writeToken(uid, newToken);
      }
    });

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Initialize local notifications (for foreground display)
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Foreground message handler — show local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // App was opened from terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  /// Step 2: Call this after successful login/signup.
  /// Writes the current FCM token to users/{uid}.fcmToken.
  Future<void> saveTokenForUser(String uid) async {
    if (_token == null) {
      // Try getting token again (might have been delayed)
      _token = await _messaging.getToken();
    }
    if (_token != null) {
      await _writeToken(uid, _token!);
    }
  }

  /// Step 3: Call this on sign-out.
  /// Removes the token so the user stops getting pushes.
  Future<void> clearToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': FieldValue.delete(),
        });
        debugPrint('FCM token cleared for user $uid');
      } catch (e) {
        debugPrint('FCM clearToken error: $e');
      }
    }
  }

  // ── Private helpers ────────────────────────────────────

  Future<void> _writeToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
      debugPrint('FCM token saved for user $uid');
    } catch (e) {
      debugPrint('FCM _writeToken error: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    // Show as local notification so the user sees it
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['orderId'],
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    debugPrint('FCM tap: ${message.data}');
    // TODO: Navigate to order detail screen using message.data['orderId']
    // This requires a GlobalKey<NavigatorState> or a navigation service.
    // For now, the app will just open to the home screen.
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tap: ${response.payload}');
    // TODO: Navigate to order detail using response.payload (orderId)
  }
}
