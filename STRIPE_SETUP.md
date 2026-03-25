# Amma Food City — Stripe Integration Setup

## 1. Create Stripe Account
- Go to https://dashboard.stripe.com/register
- Complete account setup (you can use test mode without full verification)

## 2. Get Your API Keys
- Go to https://dashboard.stripe.com/test/apikeys
- Copy your **Publishable key** (starts with `pk_test_`)
- Copy your **Secret key** (starts with `sk_test_`)

## 3. Configure Flutter App
In `lib/main.dart`, uncomment and add your publishable key:

```dart
await StripeService.init(
  publishableKey: 'pk_test_YOUR_KEY_HERE',
);
```

## 4. Configure Cloud Functions
Set your secret key using Firebase secrets (stored in Google Cloud Secret Manager):

```bash
cd firebase
firebase functions:secrets:set STRIPE_SECRET
```
Paste your `sk_test_...` key when prompted and press Enter.

Then deploy:
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

## 5. Android Setup
Add to `android/app/src/main/AndroidManifest.xml` inside `<application>`:

```xml
<meta-data
    android:name="com.google.android.gms.wallet.api.enabled"
    android:value="true" />
```

Set minimum SDK to 21 in `android/app/build.gradle`:

```gradle
minSdkVersion 21
```

## 6. iOS Setup
Add to `ios/Runner/Info.plist`:

```xml
<key>UIUserInterfaceStyle</key>
<string>Automatic</string>
```

Run `cd ios && pod install`.

## 7. Stripe Webhook (Optional for production)
For real-time payment confirmations:

```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe

# Forward webhooks to your Cloud Function
stripe listen --forward-to YOUR_CLOUD_FUNCTION_URL/stripeWebhook

# Set webhook secret using Firebase secrets
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
# Paste the whsec_... value when prompted

firebase deploy --only functions
```

## Test Cards
| Card Number          | Result            |
|---------------------|-------------------|
| 4242 4242 4242 4242 | Success           |
| 4000 0000 0000 3220 | 3D Secure required|
| 4000 0000 0000 9995 | Declined          |

Use any future expiry date and any 3-digit CVC.

## Payment Flow
1. User taps "Place Order" on checkout step 3
2. App calls `PaymentProvider.processCardPayment()`
3. Provider calls `StripeService.processPayment()`
4. Service calls Cloud Function `createPaymentIntent` → returns clientSecret
5. Service presents Stripe PaymentSheet to user
6. User enters card details and confirms
7. On success: order created via `OrdersProvider`, cart cleared, confirmation shown
8. Stripe webhook confirms payment → Cloud Function updates order status

## Files
- `lib/core/services/stripe_service.dart` — Stripe SDK wrapper
- `lib/core/providers/payment_provider.dart` — Payment state management
- `lib/features/cart/checkout_screen.dart` — UI integration
- `firebase/functions/index.js` — createPaymentIntent + stripeWebhook
