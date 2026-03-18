import "package:flutter/material.dart";

import "../route_map_viewmodel.dart";

class RouteProgressBar extends StatelessWidget {
  final RouteMapViewModel viewModel;

  const RouteProgressBar({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${vm.completedPoints} de ${vm.totalPoints} entregas",
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                "${(vm.progressPercent * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: vm.progressPercent,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                vm.progressPercent == 1 ? Colors.green : Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _Legend(
                color: Colors.green,
                label: "${vm.completedPoints} entregues",
              ),
              const SizedBox(width: 12),
              _Legend(color: Colors.red, label: "${vm.failedPoints} falhas"),
              const SizedBox(width: 12),
              _Legend(
                color: Colors.grey,
                label: "${vm.pendingPoints} pendentes",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
