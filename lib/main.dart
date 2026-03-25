import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/firebase_init.dart';
import 'core/services/stripe_service.dart';
import 'features/auth/auth_gate.dart';
// TODO: Import your generated firebase_options.dart after running flutterfire configure
import 'firebase_options.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // TODO: Uncomment after running: flutterfire configure
  await FirebaseInit.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
    useEmulator: false,
  );

  await FcmService.instance.initialize();

  // Initialize Stripe
  // TODO: Uncomment with your publishable key
  await StripeService.init(
    publishableKey:
        'pk_test_51T9NPIFby2tXmdVbURq3uPHw9zLFWDDpvqlBOYc5jXHJD2bnit8LeAoYswOYlwoxJma4f87yk7b0rLNy2SWRHwGm00V8BjaHDi',
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: AmmaFoodCityApp()));
}

class AmmaFoodCityApp extends StatelessWidget {
  const AmmaFoodCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
