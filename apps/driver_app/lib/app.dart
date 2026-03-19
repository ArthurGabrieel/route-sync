import "package:auth/auth.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "config/router/router.dart";

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final _router = buildRouter(context.read<AuthRepository>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "RouteSync",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      routerConfig: _router,
      builder: (context, child) => Column(children: [Expanded(child: child!)]),
    );
  }
}
