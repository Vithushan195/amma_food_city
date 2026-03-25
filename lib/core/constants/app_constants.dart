/// Amma Food City — App Constants
class AppStrings {
  AppStrings._();

  static const String appName = 'Amma Food City';
  static const String appTagline = 'Fresh Asian Groceries, Delivered';

  // ── Navigation Labels ────────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navCategories = 'Categories';
  static const String navCart = 'Cart';
  static const String navOrders = 'Orders';
  static const String navProfile = 'Profile';

  // ── Home Screen ──────────────────────────────────────────────────
  static const String searchHint = 'Search for groceries...';
  static const String sectionFeatured = 'Featured';
  static const String sectionPopular = 'Popular Items';
  static const String sectionNewArrivals = 'New Arrivals';
  static const String sectionOffers = 'Special Offers';

  // ── Cart ─────────────────────────────────────────────────────────
  static const String cartEmpty = 'Your cart is empty';
  static const String cartCheckout = 'Proceed to Checkout';
  static const String cartSubtotal = 'Subtotal';
  static const String cartDelivery = 'Delivery Fee';
  static const String cartTotal = 'Total';

  // ── Auth ─────────────────────────────────────────────────────────
  static const String loginTitle = 'Welcome Back';
  static const String signupTitle = 'Create Account';
  static const String loginCta = 'Sign In';
  static const String signupCta = 'Sign Up';

  // ── General ──────────────────────────────────────────────────────
  static const String viewAll = 'View All';
  static const String addToCart = 'Add to Cart';
  static const String currency = '£';
}

/// Named routes for GoRouter / Navigator
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String categoryDetail = '/categories/:id';
  static const String productDetail = '/product/:id';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String signup = '/signup';
}

/// Asset paths (placeholder structure — populate with actual asset files)
class AppAssets {
  AppAssets._();

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  static const String logo = '$_images/logo.png';
  static const String logoWhite = '$_images/logo_white.png';
  static const String placeholder = '$_images/placeholder.png';
  static const String emptyCart = '$_images/empty_cart.png';
  static const String onboarding1 = '$_images/onboarding_1.png';
  static const String onboarding2 = '$_images/onboarding_2.png';
}
