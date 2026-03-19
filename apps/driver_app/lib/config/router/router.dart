import "package:go_router/go_router.dart";
import "package:auth/auth.dart";
import "package:core/core.dart";
import "package:deliveries/deliveries.dart";
import "package:provider/provider.dart";
import "package:route/route.dart";

import "routes.dart";

GoRouter buildRouter(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.deliveries,
  debugLogDiagnostics: true,
  refreshListenable: StreamToListenable(authRepository.driverStream),
  redirect: (context, state) {
    final isAuthenticated = authRepository.isAuthenticated;
    final isLoggingIn = state.matchedLocation == Routes.login;

    if (!isAuthenticated && !isLoggingIn) return Routes.login;
    if (isAuthenticated && isLoggingIn) return Routes.deliveries;
    return null;
  },
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) => LoginPage(
        viewModel: LoginViewModel(
          context.read<AuthRepository>(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.deliveries,
      builder: (context, state) => DeliveriesListPage(
        viewModel: DeliveriesListViewModel(
          context.read<DeliveriesRepository>(),
        ),
      ),
      routes: [
        GoRoute(
          path: ":id",
          builder: (context, state) => DeliveryDetailPage(
            viewModel: DeliveryDetailViewModel(
              repository: context.read<DeliveriesRepository>(),
              deliveryId: state.pathParameters["id"]!,
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      path: Routes.route,
      builder: (context, state) => RouteMapPage(
        viewModel: RouteMapViewModel(
          routeRepository: context.read<RouteRepository>(),
          deliveriesRepository: context.read<DeliveriesRepository>(),
        ),
      ),
    ),
  ],
);
