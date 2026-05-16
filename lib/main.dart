import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'firebase/config_service.dart';
import 'firebase/notification_service.dart';
import 'core/theme.dart';
import 'core/router.dart';

Future<void> _enforceValidStartupSession() async {
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser;

  if (user == null) return;

  try {
    await user.getIdToken(true);
  } on FirebaseAuthException catch (e) {
    const invalidCodes = {
      'user-disabled',
      'user-not-found',
      'invalid-user-token',
      'user-token-expired',
      'requires-recent-login',
    };

    if (invalidCodes.contains(e.code)) {
      await auth.signOut();
    }
  }
}

Future<void> _configureAppCheck() async {
  try {
    final recaptchaKey = ConfigService().recaptchaSiteKey;
    if (recaptchaKey.isNotEmpty) {
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
        webProvider: ReCaptchaEnterpriseProvider(recaptchaKey),
      );
    } else {
      // On mobile, still activate with platform provider even without web key.
      if (!kIsWeb) {
        await FirebaseAppCheck.instance.activate(
          androidProvider: kDebugMode
              ? AndroidProvider.debug
              : AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.deviceCheck,
        );
      }
    }
  } catch (e) {
    debugPrint('App Check activation failed: $e');
  }
}

Future<void> _runDeferredStartupTasks() async {
  try {
    await Future.wait([
      _enforceValidStartupSession(),
      ConfigService().initialize(),
    ]);
    await _configureAppCheck();
    await NotificationService().initialize();

    // Initialise Firebase Analytics — required for DAU / retention data.
    // Must be called after Firebase.initializeApp().
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    debugPrint('[Analytics] Firebase Analytics enabled');
  } catch (e) {
    debugPrint('Deferred startup initialization failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Keep auth sessions stable across web refreshes so callable auth is available.
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  // Defer non-critical startup tasks so first frame and routing are not blocked.
  unawaited(_runDeferredStartupTasks());

  runApp(const ProviderScope(child: GoldenCareApp()));
}

class GoldenCareApp extends ConsumerWidget {
  const GoldenCareApp({super.key});

  // Single shared Analytics instance + observer for automatic screen tracking.
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _analyticsObserver =
      FirebaseAnalyticsObserver(analytics: _analytics);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'GoldenCare',
      theme: gcTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
