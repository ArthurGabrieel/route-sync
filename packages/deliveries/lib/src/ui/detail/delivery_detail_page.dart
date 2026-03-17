import "package:flutter/material.dart";
import "package:core/core.dart";

import "../../data/models/delivery_status.dart";
import "delivery_detail_viewmodel.dart";
import "widgets/delivery_action_buttons.dart";
import "widgets/pending_indicator.dart";

class DeliveryDetailPage extends StatefulWidget {
  final DeliveryDetailViewModel viewModel;

  const DeliveryDetailPage({required this.viewModel, super.key});

  @override
  State<DeliveryDetailPage> createState() => _DeliveryDetailPageState();
}

class _DeliveryDetailPageState extends State<DeliveryDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.start.addListener(_onActionResult);
    widget.viewModel.confirm.addListener(_onActionResult);
    widget.viewModel.fail.addListener(_onActionResult);
  }

  void _onActionResult() {
    final commands = [
      widget.viewModel.start,
      widget.viewModel.confirm,
      widget.viewModel.fail,
    ];

    for (final cmd in commands) {
      if (cmd.value case FailureCommand(:final error)) {
        context.showErrorSnackBar(error.toString());
        return;
      }
      if (cmd.value case SuccessCommand()) {
        context.showSuccessSnackBar("Entrega atualizada");
        return;
      }
    }
  }

  @override
  void dispose() {
    widget.viewModel.start.removeListener(_onActionResult);
    widget.viewModel.confirm.removeListener(_onActionResult);
    widget.viewModel.fail.removeListener(_onActionResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final delivery = vm.delivery;

        if (delivery == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(delivery.recipientName),
            actions: [
              if (vm.isPending)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: PendingIndicator(),
                ),
            ],
          ),
          body: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: SingleChildScrollView(
                  padding: 16.0.paddingAll,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle("Status"),
                      _StatusBadge(status: delivery.status),
                      const SizedBox(height: 24),
                      const _SectionTitle("Destinatário"),
                      _InfoRow(
                        icon: Icons.person_outline,
                        text: delivery.recipientName,
                      ),
                      const _SectionTitle("Endereço"),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: delivery.address,
                      ),
                      const _SectionTitle("Janela de entrega"),
                      _InfoRow(
                        icon: Icons.schedule_outlined,
                        text: delivery.scheduledWindow,
                      ),
                      const _SectionTitle("Itens"),
                      ...delivery.items.map(
                        (item) => _InfoRow(
                          icon: Icons.inventory_2_outlined,
                          text: item,
                        ),
                      ),
                      if (delivery.notes != null) ...[
                        const _SectionTitle("Observações"),
                        _InfoRow(
                          icon: Icons.notes_outlined,
                          text: delivery.notes!,
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              DeliveryActionButtons(viewModel: vm),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: context.colorPalette.outline,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.colorPalette.outline),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DeliveryStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.label),
      backgroundColor: switch (status) {
        DeliveryStatus.pending => Colors.grey.shade100,
        DeliveryStatus.inProgress => Colors.blue.shade50,
        DeliveryStatus.delivered => Colors.green.shade50,
        DeliveryStatus.failed => Colors.red.shade50,
      },
    );
  }
}
