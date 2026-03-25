# Amma Food City

A Flutter e-commerce app for a UK-based Asian grocery store. Built with Flutter, Firebase, Stripe, and Riverpod.

## Tech Stack

- **Flutter 3.27+** — Cross-platform UI
- **Firebase** — Auth, Firestore, Cloud Functions, Cloud Messaging
- **Stripe** — Card payments via PaymentSheet
- **Riverpod** — State management
- **SharedPreferences** — Onboarding flag

## Architecture

```
lib/
├── main.dart                          # Entry point → AuthGate
├── core/
│   ├── config/
│   │   └── env_config.dart           # Dev/staging/production environments
│   ├── constants/
│   │   └── app_constants.dart        # Strings, routes, assets
│   ├── models/
│   │   ├── app_order.dart            # Order with status enum
│   │   ├── app_user.dart             # User profile
│   │   ├── cart_item.dart            # Cart item with subtotal
│   │   ├── category.dart             # Product category
│   │   ├── delivery_address.dart     # Address with default flag
│   │   ├── product.dart              # Product with variants
│   │   └── promo_banner.dart         # Home carousel banner
│   ├── providers/
│   │   ├── auth_provider.dart        # Auth state + sign in/out
│   │   ├── cart_provider.dart        # Cart CRUD + computed totals
│   │   ├── data_providers.dart       # Mock ↔ Firestore toggle
│   │   ├── orders_provider.dart      # Order history + place/cancel
│   │   ├── payment_provider.dart     # Stripe + cash payment flow
│   │   ├── promo_provider.dart       # Promo code validation
│   │   └── service_providers.dart    # Firestore service singletons
│   ├── services/
│   │   ├── category_service.dart     # Firestore categories
│   │   ├── firebase_init.dart        # Firebase setup helper
│   │   ├── firestore_seed.dart       # Database seed script
│   │   ├── order_service.dart        # Firestore orders CRUD
│   │   ├── product_service.dart      # Cached product queries
│   │   ├── promo_service.dart        # Banner + code validation
│   │   ├── stripe_service.dart       # Stripe PaymentSheet
│   │   └── user_service.dart         # User profiles + addresses
│   ├── theme/
│   │   ├── app_colors.dart           # Design tokens
│   │   ├── app_spacing.dart          # 4px grid system
│   │   ├── app_theme.dart            # Material ThemeData
│   │   └── app_typography.dart       # Playfair + DM Sans
│   └── utils/
│       └── page_transitions.dart     # SlideUp, FadeScale routes
├── features/
│   ├── auth/
│   │   ├── auth_gate.dart            # Launch flow controller
│   │   ├── forgot_password_screen.dart
│   │   ├── login_screen.dart         # Email + Phone OTP
│   │   └── signup_screen.dart
│   ├── cart/
│   │   ├── cart_screen.dart          # Cart + auth guard
│   │   └── checkout_screen.dart      # 4-step: address → slot → pay → confirm
│   ├── categories/
│   │   ├── categories_screen.dart    # Grid + diet filters
│   │   └── category_detail_screen.dart # Sort + grid/list toggle
│   ├── home/
│   │   └── home_screen.dart          # Header → categories → banners → products
│   ├── onboarding/
│   │   └── onboarding_screen.dart    # 3 swipeable pages
│   ├── orders/
│   │   ├── order_detail_screen.dart  # Timeline + items + summary
│   │   ├── order_tracking_screen.dart # Live status + map placeholder
│   │   └── orders_screen.dart        # Filter tabs + order cards
│   ├── product/
│   │   └── product_detail_screen.dart # Variants + nutrition + related
│   ├── profile/
│   │   ├── contact_us_screen.dart    # Contact cards + message form
│   │   ├── dev_tools_screen.dart     # Database seed buttons
│   │   ├── edit_profile_screen.dart  # Name, email, phone editing
│   │   ├── help_centre_screen.dart   # Searchable FAQ accordion
│   │   ├── notifications_screen.dart # Grouped + read/unread
│   │   ├── profile_screen.dart       # Settings hub
│   │   └── saved_addresses_screen.dart # CRUD + set default
│   ├── search/
│   │   └── search_screen.dart        # Debounced + recent + trending
│   └── splash/
│       └── splash_screen.dart        # Animated branding
└── widgets/                           # 14 reusable components
    ├── app_search_bar.dart
    ├── cart_badge.dart
    ├── category_circle.dart
    ├── circular_qty_control.dart
    ├── curved_header.dart
    ├── delivery_address_bar.dart
    ├── error_state.dart
    ├── horizontal_product_list.dart
    ├── lime_cta.dart
    ├── product_card.dart
    ├── promo_banner_carousel.dart
    ├── section_header.dart
    ├── shimmer_loading.dart
    └── superscript_price.dart
```

## Quick Start

```bash
# Clone
git clone <repo>
cd amma_food_city

# Install dependencies
flutter pub get

# Run in development (mock data)
flutter run

# Run tests
flutter test
```

## Firebase Setup

```bash
# Configure
flutterfire configure --project=YOUR_PROJECT_ID

# Uncomment in main.dart:
# await FirebaseInit.initialize(options: DefaultFirebaseOptions.currentPlatform);

# Deploy
cd firebase
firebase deploy --only firestore:rules,firestore:indexes
cd functions && npm install && cd ..
firebase functions:secrets:set STRIPE_SECRET
firebase deploy --only functions

# Seed data (in-app)
# Profile > tap version 5x > DevTools > Seed Everything

# Switch to Firestore
# Set _useFirestore = true in lib/core/providers/data_providers.dart
```

## Build

```bash
# Android
flutter build appbundle --release --dart-define=ENV=production

# iOS
flutter build ipa --release --dart-define=ENV=production
```

## Test Cards

| Number | Result |
|--------|--------|
| 4242 4242 4242 4242 | Success |
| 4000 0000 0000 3220 | 3D Secure |
| 4000 0000 0000 9995 | Declined |

## Design System

- **Primary:** #0B3B2D (dark green)
- **Accent:** #A8E06C (lime)
- **Headings:** Playfair Display
- **Body:** DM Sans
- **Grid:** 4px base unit
- **Cards:** 16px radius
- **Buttons:** 14px radius, 52px height

## License

Proprietary — Amma Food City Ltd.
