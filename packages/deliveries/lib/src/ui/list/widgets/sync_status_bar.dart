import "package:core/core.dart";
import "package:flutter/material.dart";

import "../deliveries_list_viewmodel.dart";

class SyncStatusBar extends StatelessWidget {
  final DeliveriesListViewModel viewModel;

  const SyncStatusBar({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel.sync,
      builder: (context, _) {
        if (viewModel.sync.value is RunningCommand) {
          return Container(
            width: double.infinity,
            color: Colors.blue.shade50,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: const Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  "Sincronizando...",
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
