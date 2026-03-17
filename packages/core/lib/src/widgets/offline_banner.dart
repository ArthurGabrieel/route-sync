import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../connectivity/connectivity_repository.dart";

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isOffline = context.select<ConnectivityRepository, bool>(
      (repo) => repo.isOffline,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isOffline
          ? Container(
              key: const ValueKey("offline"),
              width: double.infinity,
              color: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "Sem conexão — operações serão sincronizadas ao voltar online",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey("online")),
    );
  }
}
