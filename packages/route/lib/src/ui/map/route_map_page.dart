import "package:deliveries/deliveries.dart";
import "package:flutter/material.dart";
import "package:core/core.dart";

import "../../../route.dart";
import "widgets/route_progress_bar.dart";

class RouteMapScreen extends StatefulWidget {
  final RouteMapViewModel viewModel;

  const RouteMapScreen({required this.viewModel, super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load.addListener(_onLoadResult);
    widget.viewModel.load.execute();
  }

  @override
  void dispose() {
    widget.viewModel.load.removeListener(_onLoadResult);
    super.dispose();
  }

  void _onLoadResult() {
    final cmd = widget.viewModel.load;
    if (cmd.value case FailureCommand(:final error)) {
      context.showErrorSnackBar(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Rota do dia"),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: RouteProgressBar(viewModel: vm),
            ),
          ),
          body: Column(
            children: [
              const OfflineBanner(),
              if (vm.nextPoint != null) _NextPointBanner(viewModel: vm),
              Expanded(
                child: vm.route == null
                    ? const Center(child: CircularProgressIndicator())
                    : _RouteList(viewModel: vm),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NextPointBanner extends StatelessWidget {
  final RouteMapViewModel viewModel;

  const _NextPointBanner({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final next = viewModel.nextPoint!;

    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: 12.0.paddingAll,
      child: Row(
        children: [
          const Icon(Icons.navigation, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Próxima parada — #${next.order}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  next.recipientName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  next.address,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (viewModel.estimatedTimeLeft != "--")
            Column(
              children: [
                Text(
                  viewModel.estimatedTimeLeft,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Text(
                  "restante",
                  style: TextStyle(fontSize: 10, color: Colors.blue),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RouteList extends StatelessWidget {
  final RouteMapViewModel viewModel;

  const _RouteList({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final points = viewModel.route!.points;

    return ListView.separated(
      padding: 16.0.paddingAll,
      itemCount: points.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final point = points[i];
        final status = viewModel.statusOf(point);
        final isNext = viewModel.nextPoint?.deliveryId == point.deliveryId;

        return _RoutePointTile(point: point, status: status, isNext: isNext);
      },
    );
  }
}

class _RoutePointTile extends StatelessWidget {
  final RoutePointModel point;
  final DeliveryStatus status;
  final bool isNext;

  const _RoutePointTile({
    required this.point,
    required this.status,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isNext ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isNext
            ? const BorderSide(color: Colors.blue, width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor.withValues(alpha: .15),
          child: Text(
            "${point.order}",
            style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          point.recipientName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(point.address, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(
              point.scheduledWindow,
              style: TextStyle(
                fontSize: 11,
                color: context.colorPalette.outline,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(_statusIcon, color: _statusColor, size: 20),
            if (point.distanceToNextKm != null)
              Text(
                "${point.distanceToNextKm!.toStringAsFixed(1)}km",
                style: TextStyle(
                  fontSize: 11,
                  color: context.colorPalette.outline,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor => switch (status) {
    DeliveryStatus.pending => Colors.grey,
    DeliveryStatus.inProgress => Colors.blue,
    DeliveryStatus.delivered => Colors.green,
    DeliveryStatus.failed => Colors.red,
  };

  IconData get _statusIcon => switch (status) {
    DeliveryStatus.pending => Icons.radio_button_unchecked,
    DeliveryStatus.inProgress => Icons.directions_run,
    DeliveryStatus.delivered => Icons.check_circle,
    DeliveryStatus.failed => Icons.cancel,
  };
}
