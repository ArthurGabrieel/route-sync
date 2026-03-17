import "package:flutter/material.dart";
import "package:core/core.dart";

import "../../../data/models/delivery_model.dart";
import "../../../data/models/delivery_status.dart";

class DeliveryTile extends StatelessWidget {
  final DeliveryModel delivery;
  final bool isPending;
  final VoidCallback? onTap;

  const DeliveryTile({
    required this.delivery,
    required this.isPending,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: _StatusIcon(status: delivery.status, isPending: isPending),
        title: Text(
          delivery.recipientName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              delivery.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            4.0.paddingTop.top > 0
                ? const SizedBox(height: 4)
                : const SizedBox.shrink(),
            Text(
              delivery.scheduledWindow,
              style: TextStyle(
                fontSize: 12,
                color: context.colorPalette.outline,
              ),
            ),
          ],
        ),
        trailing: _StatusChip(status: delivery.status, isPending: isPending),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final DeliveryStatus status;
  final bool isPending;

  const _StatusIcon({required this.status, required this.isPending});

  @override
  Widget build(BuildContext context) {
    if (isPending) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
      );
    }

    return Icon(
      switch (status) {
        DeliveryStatus.pending => Icons.radio_button_unchecked,
        DeliveryStatus.inProgress => Icons.directions_run,
        DeliveryStatus.delivered => Icons.check_circle,
        DeliveryStatus.failed => Icons.cancel,
      },
      color: switch (status) {
        DeliveryStatus.pending => Colors.grey,
        DeliveryStatus.inProgress => Colors.blue,
        DeliveryStatus.delivered => Colors.green,
        DeliveryStatus.failed => Colors.red,
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DeliveryStatus status;
  final bool isPending;

  const _StatusChip({required this.status, required this.isPending});

  @override
  Widget build(BuildContext context) {
    if (isPending) {
      return Chip(
        label: const Text(
          "Pendente",
          style: TextStyle(fontSize: 11, color: Colors.orange),
        ),
        backgroundColor: Colors.orange.shade50,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    }

    return Chip(
      label: Text(
        status.label,
        style: TextStyle(fontSize: 11, color: _textColor),
      ),
      backgroundColor: _bgColor,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Color get _bgColor => switch (status) {
    DeliveryStatus.pending => Colors.grey.shade100,
    DeliveryStatus.inProgress => Colors.blue.shade50,
    DeliveryStatus.delivered => Colors.green.shade50,
    DeliveryStatus.failed => Colors.red.shade50,
  };

  Color get _textColor => switch (status) {
    DeliveryStatus.pending => Colors.grey,
    DeliveryStatus.inProgress => Colors.blue,
    DeliveryStatus.delivered => Colors.green,
    DeliveryStatus.failed => Colors.red,
  };
}
