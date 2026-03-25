# Amma Food City — Launch Checklist

## Phase 1: Pre-Launch Setup

### Firebase Configuration
- [ ] Run `flutterfire configure --project=YOUR_PROJECT_ID`
- [ ] Uncomment Firebase init in `lib/main.dart`
- [ ] Enable Authentication (Email/Password + Phone) in Firebase Console
- [ ] Enable Cloud Firestore (start in production mode)
- [ ] Deploy security rules: `firebase deploy --only firestore:rules`
- [ ] Deploy indexes: `firebase deploy --only firestore:indexes`
- [ ] Deploy Cloud Functions: `cd firebase/functions && npm install && cd .. && firebase deploy --only functions`
- [ ] Set Stripe secret: `firebase functions:secrets:set STRIPE_SECRET`
- [ ] Seed database via DevTools screen (Profile > tap version 5x > Seed Everything)
- [ ] Set `_useFirestore = true` in `lib/core/providers/data_providers.dart`
- [ ] Verify all data loads from Firestore

### Stripe Configuration
- [ ] Create Stripe account at dashboard.stripe.com
- [ ] Get publishable key (pk_test_ or pk_live_)
- [ ] Uncomment Stripe init in `lib/main.dart` with your key
- [ ] Test payment with card 4242 4242 4242 4242
- [ ] Test 3D Secure with card 4000 0000 0000 3220
- [ ] Test declined card 4000 0000 0000 9995
- [ ] Set up Stripe webhook (optional for production)

### Environment Configuration
- [ ] Update `lib/core/config/env_config.dart` with real keys
- [ ] Test dev build: `flutter run --dart-define=ENV=dev`
- [ ] Test production build: `flutter run --release --dart-define=ENV=production`

---

## Phase 2: App Polish

### App Icon
- [ ] Create 1024x1024 app icon PNG (no alpha channel)
- [ ] Place at `assets/icon/app_icon.png`
- [ ] Create foreground icon for adaptive (Android) at `assets/icon/app_icon_foreground.png`
- [ ] Add `flutter_launcher_icons: ^0.14.1` to dev_dependencies
- [ ] Run `flutter pub run flutter_launcher_icons`

### Native Splash Screen
- [ ] Add `flutter_native_splash: ^2.4.0` to dev_dependencies
- [ ] Run `flutter pub run flutter_native_splash:create`

### Product Images
- [ ] Upload product images to Firebase Storage
- [ ] Update product documents in Firestore with imageUrl fields
- [ ] Verify images load via CachedNetworkImage

### Content
- [ ] Write Terms & Conditions page content
- [ ] Write Privacy Policy page content
- [ ] Host privacy policy at ammafoodcity.co.uk/privacy
- [ ] Replace mock notification data with real FCM integration

---

## Phase 3: Testing

### Run Unit Tests
- [ ] `flutter test test/models_test.dart`
- [ ] `flutter test test/providers/cart_provider_test.dart`
- [ ] `flutter test test/providers/auth_provider_test.dart`
- [ ] `flutter test test/providers/promo_provider_test.dart`
- [ ] `flutter test test/providers/orders_provider_test.dart`
- [ ] `flutter test` (run all)

### Manual Testing Checklist
- [ ] Splash → Onboarding → Login flow (first launch)
- [ ] Splash → Login flow (returning user)
- [ ] Email login
- [ ] Phone OTP login
- [ ] Sign up with new account
- [ ] Forgot password flow
- [ ] Continue as Guest
- [ ] Browse home screen (featured, popular, offers load)
- [ ] Search products
- [ ] Browse categories and category detail
- [ ] Product detail (weight variants, nutrition, related)
- [ ] Add to cart from home/categories/search/product detail
- [ ] Cart: update quantities, swipe to delete, undo
- [ ] Cart: apply promo code AMMA10 and WELCOME
- [ ] Cart: auth guard (guest can't checkout)
- [ ] Checkout: address selection
- [ ] Checkout: delivery date + time slot
- [ ] Checkout: card payment (Stripe)
- [ ] Checkout: cash on delivery
- [ ] Checkout: confirmation screen
- [ ] Order tracking from confirmation
- [ ] Orders tab: filter all/active/completed
- [ ] Order detail: timeline, items, summary
- [ ] Reorder from order detail
- [ ] Cancel pending order
- [ ] Profile: edit profile
- [ ] Profile: saved addresses (add/edit/delete/set default)
- [ ] Profile: notifications
- [ ] Profile: help centre search + FAQ
- [ ] Profile: contact us form
- [ ] Profile: sign out
- [ ] Sign out returns to login (not guest mode)

### Edge Cases
- [ ] Empty cart state
- [ ] No search results state
- [ ] Network error handling
- [ ] Back button behavior on each screen
- [ ] Keyboard handling on forms
- [ ] Long product names truncation
- [ ] Landscape orientation (should be locked to portrait)
- [ ] Small screen (320dp width)
- [ ] Large screen (tablet)

---

## Phase 4: Build & Release

### Android (Play Store)

#### Generate Signing Key
- [ ] Follow `android/SIGNING_GUIDE.md`
- [ ] Create `android/key.properties` (NOT in git)
- [ ] Update `android/app/build.gradle` with signing config

#### Build Release APK/AAB
```bash
# App Bundle (recommended for Play Store)
flutter build appbundle --release --dart-define=ENV=production --dart-define=STRIPE_PK=pk_live_YOUR_KEY

# APK (for direct distribution)
flutter build apk --release --split-per-abi --dart-define=ENV=production
```

#### Play Store Submission
- [ ] Create developer account at play.google.com/console ($25 one-time)
- [ ] Create new app "Amma Food City"
- [ ] Fill in store listing from `STORE_LISTING.md`
- [ ] Upload screenshots (minimum 2, recommended 8)
- [ ] Upload feature graphic (1024x500)
- [ ] Set content rating (complete questionnaire)
- [ ] Set pricing (Free)
- [ ] Select countries (United Kingdom)
- [ ] Upload AAB to Internal Testing track first
- [ ] Test on 3+ real devices
- [ ] Promote to Production track
- [ ] Submit for review

### iOS (App Store)

#### Xcode Setup
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Set Bundle Identifier: `com.ammafoodcity.app`
- [ ] Set Display Name: `Amma Food City`
- [ ] Set Team (Apple Developer account)
- [ ] Set minimum iOS version to 14.0
- [ ] Enable Push Notifications capability
- [ ] Enable Apple Pay capability (for Stripe)
- [ ] Add NSCameraUsageDescription (for future photo upload)
- [ ] Add NSLocationWhenInUseUsageDescription (for future delivery tracking)

#### Build Release IPA
```bash
flutter build ipa --release --dart-define=ENV=production --dart-define=STRIPE_PK=pk_live_YOUR_KEY
```

#### App Store Submission
- [ ] Create app in App Store Connect
- [ ] Upload IPA via Xcode or Transporter
- [ ] Fill in App Information from `STORE_LISTING.md`
- [ ] Upload screenshots for all required device sizes
- [ ] Set app review information (demo account credentials)
- [ ] Submit for review

---

## Phase 5: Post-Launch

### Monitoring
- [ ] Enable Firebase Crashlytics
- [ ] Enable Firebase Analytics
- [ ] Set up Stripe webhook for payment monitoring
- [ ] Monitor Cloud Functions logs
- [ ] Set up uptime monitoring for Cloud Functions

### Updates
- [ ] Plan v1.1 features (live tracking map, payment methods screen, language selector)
- [ ] Collect user feedback
- [ ] Monitor app reviews
- [ ] Plan marketing (social media, local flyers, in-store QR code)

---

## Quick Reference: Build Commands

```bash
# Development
flutter run

# Development with env
flutter run --dart-define=ENV=dev

# Production test
flutter run --release --dart-define=ENV=production --dart-define=STRIPE_PK=pk_test_XXX

# Run all tests
flutter test

# Build Android release
flutter build appbundle --release --dart-define=ENV=production

# Build iOS release
flutter build ipa --release --dart-define=ENV=production

# Analyze code
flutter analyze

# Check for outdated packages
flutter pub outdated
```
