import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:auth/auth.dart";
import "package:core/core.dart";

import "app.dart";
import "config/providers/app_providers.dart";

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final authRepository = AuthRepository(
    AuthRemoteService(),
    AuthLocalService(prefs),
  );

  await authRepository.initialize();

  runApp(
    AppProviders(
      prefs: prefs,
      child: const App(),
    ),
  );
}
