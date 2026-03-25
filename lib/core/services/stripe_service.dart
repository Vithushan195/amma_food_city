import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Result of a payment attempt.
class PaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String? error;

  const PaymentResult({
    required this.success,
    this.paymentIntentId,
    this.error,
  });
}

/// Stripe payment service for Amma Food City.
///
/// Setup:
///   1. Get keys from https://dashboard.stripe.com/test/apikeys
///   2. Call StripeService.init(publishableKey: 'pk_test_...') in main.dart
///   3. Deploy the createPaymentIntent Cloud Function
///   4. Set stripe.secret in Firebase config
///
/// Test card: 4242 4242 4242 4242, any future expiry, any 3-digit CVC
class StripeService {
  StripeService._();

  static bool _initialized = false;

  /// Initialize Stripe SDK. Call once in main() after Firebase init.
  static Future<void> init({required String publishableKey}) async {
    if (_initialized) return;

    Stripe.publishableKey = publishableKey;
    Stripe.merchantIdentifier = 'merchant.com.ammafoodcity';
    Stripe.urlScheme = 'ammafoodcity';
    await Stripe.instance.applySettings();

    _initialized = true;
    debugPrint('StripeService: initialized');
  }

  /// Full payment flow:
  /// 1. Call Cloud Function to create PaymentIntent
  /// 2. Initialize PaymentSheet with client secret
  /// 3. Present PaymentSheet to user
  /// 4. Return result with paymentIntentId on success
  static Future<PaymentResult> processPayment({
    required double amount,
    String currency = 'gbp',
    String? orderId,
    String? customerEmail,
  }) async {
    if (!_initialized) {
      return const PaymentResult(
        success: false,
        error: 'Stripe not initialized. Call StripeService.init() first.',
      );
    }

    try {
      // Step 1: Create PaymentIntent via Cloud Function
      final intentData = await _createPaymentIntent(
        amount: amount,
        currency: currency,
        orderId: orderId,
      );

      final clientSecret = intentData['clientSecret'] as String;
      final paymentIntentId = intentData['paymentIntentId'] as String;

      // Step 2: Initialize PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Amma Food City',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF0B3B2D),
              background: Color(0xFFFFFFFF),
              componentBackground: Color(0xFFF8F9FA),
              componentBorder: Color(0xFFDDE0E4),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 14,
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFA8E06C),
                  text: Color(0xFF1A1D21),
                ),
              ),
            ),
          ),
          billingDetails: customerEmail != null
              ? BillingDetails(email: customerEmail)
              : null,
        ),
      );

      // Step 3: Present PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Success — user completed payment
      debugPrint('StripeService: payment succeeded ($paymentIntentId)');
      return PaymentResult(
        success: true,
        paymentIntentId: paymentIntentId,
      );
    } on StripeException catch (e) {
      // User cancelled or card declined
      final code = e.error.code;
      if (code == FailureCode.Canceled) {
        debugPrint('StripeService: user cancelled');
        return const PaymentResult(
          success: false,
          error: 'Payment cancelled',
        );
      }
      debugPrint('StripeService: Stripe error — ${e.error.message}');
      return PaymentResult(
        success: false,
        error: e.error.localizedMessage ?? e.error.message ?? 'Payment failed',
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('StripeService: Cloud Function error — ${e.message}');
      return const PaymentResult(
        success: false,
        error: 'Payment service error. Please try again.',
      );
    } catch (e) {
      debugPrint('StripeService: unexpected error — $e');
      return const PaymentResult(
        success: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Call the createPaymentIntent Cloud Function.
  static Future<Map<String, dynamic>> _createPaymentIntent({
    required double amount,
    required String currency,
    String? orderId,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'createPaymentIntent',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );

    final response = await callable.call<Map<String, dynamic>>({
      'amount': amount,
      'currency': currency,
      'orderId': orderId ?? '',
    });

    return response.data;
  }

  /// Confirm a payment after order creation (for deferred confirmation flow).
  static Future<PaymentResult> confirmPayment(String clientSecret) async {
    try {
      final intent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
      );

      if (intent.status == PaymentIntentsStatus.Succeeded) {
        return PaymentResult(
          success: true,
          paymentIntentId: intent.id,
        );
      }

      return PaymentResult(
        success: false,
        error: 'Payment status: ${intent.status}',
      );
    } on StripeException catch (e) {
      return PaymentResult(
        success: false,
        error: e.error.localizedMessage ?? 'Payment confirmation failed',
      );
    }
  }
}
