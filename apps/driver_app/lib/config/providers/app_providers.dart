import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:core/core.dart";
import "package:auth/auth.dart";
import "package:deliveries/deliveries.dart";
import "package:route/route.dart";

class AppProviders extends StatelessWidget {
  final Widget child;
  final SharedPreferences prefs;

  const AppProviders({required this.child, required this.prefs, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Core ──────────────────────────────────────────────────────────────
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(Connectivity()),
        ),
        Provider<ConnectivityRepository>(
          create: (context) =>
              ConnectivityRepository(context.read<ConnectivityService>()),
          dispose: (_, repo) => repo.dispose(),
        ),
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(),
        ),

        // ── Auth ──────────────────────────────────────────────────────────────
        Provider<AuthLocalService>(create: (_) => AuthLocalService(prefs)),
        Provider<AuthRemoteService>(create: (_) => AuthRemoteService()),
        Provider<AuthRepository>(
          create: (context) => AuthRepository(
            context.read<AuthRemoteService>(),
            context.read<AuthLocalService>(),
          ),
          dispose: (_, repo) => repo.dispose(),
        ),

        // ── Deliveries ────────────────────────────────────────────────────────
        Provider<DeliveriesLocalService>(
          create: (context) =>
              DeliveriesLocalService(context.read<AppDatabase>()),
        ),
        Provider<DeliveriesRemoteService>(
          create: (_) => DeliveriesRemoteService(),
        ),
        Provider<DeliveriesRepository>(
          create: (context) => DeliveriesRepository(
            context.read<DeliveriesRemoteService>(),
            context.read<DeliveriesLocalService>(),
            context.read<ConnectivityRepository>(),
          ),
          dispose: (_, repo) => repo.dispose(),
        ),

        // ── Route ─────────────────────────────────────────────────────────────
        Provider<RouteLocalService>(create: (_) => RouteLocalService(prefs)),
        Provider<RouteRemoteService>(create: (_) => RouteRemoteService()),
        Provider<RouteRepository>(
          create: (context) => RouteRepository(
            context.read<RouteRemoteService>(),
            context.read<RouteLocalService>(),
            context.read<ConnectivityRepository>(),
          ),
          dispose: (_, repo) => repo.dispose(),
        ),
      ],
      child: child,
    );
  }
}
