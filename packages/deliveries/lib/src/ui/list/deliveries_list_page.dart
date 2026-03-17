import "package:flutter/material.dart";
import "package:core/core.dart";

import "../../data/models/delivery_status.dart";
import "deliveries_list_viewmodel.dart";
import "widgets/delivery_tile.dart";
import "widgets/sync_status_bar.dart";

class DeliveriesListPage extends StatefulWidget {
  final DeliveriesListViewModel viewModel;

  const DeliveriesListPage({required this.viewModel, super.key});

  @override
  State<DeliveriesListPage> createState() => _DeliveriesListPageState();
}

class _DeliveriesListPageState extends State<DeliveriesListPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load.addListener(_onLoadResult);
    widget.viewModel.load.execute();
  }

  void _onLoadResult() {
    final cmd = widget.viewModel.load;
    if (cmd.value case FailureCommand(:final error)) {
      context.showErrorSnackBar(error.toString());
    }
  }

  @override
  void dispose() {
    widget.viewModel.load.removeListener(_onLoadResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Entregas do dia"),
            actions: [
              if (vm.hasPending)
                Padding(
                  padding: 16.0.paddingRight,
                  child: Chip(
                    avatar: const Icon(Icons.sync, size: 16),
                    label: Text("${vm.pendingCount}"),
                    backgroundColor: Colors.orange.shade100,
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              const OfflineBanner(),
              SyncStatusBar(viewModel: vm),
              _FilterBar(viewModel: vm),
              Expanded(child: _DeliveriesList(viewModel: vm)),
            ],
          ),
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  final DeliveriesListViewModel viewModel;

  const _FilterBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: 8.0.paddingHorizontal,
      child: Row(
        children: [
          _FilterChip(
            label: "Todas",
            selected: viewModel.activeFilter == null,
            onTap: () => viewModel.setFilter(null),
          ),
          ...DeliveryStatus.values.map(
            (status) => _FilterChip(
              label: status.label,
              selected: viewModel.activeFilter == status,
              onTap: () => viewModel.setFilter(status),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: 4.0.paddingHorizontal,
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _DeliveriesList extends StatelessWidget {
  final DeliveriesListViewModel viewModel;

  const _DeliveriesList({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.deliveries.isEmpty) {
      return const Center(child: Text("Nenhuma entrega encontrada"));
    }

    return RefreshIndicator(
      onRefresh: () async => viewModel.load.execute(),
      child: ListView.separated(
        padding: 16.0.paddingAll,
        itemCount: viewModel.deliveries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final delivery = viewModel.deliveries[i];
          return DeliveryTile(
            delivery: delivery,
            isPending: viewModel.isPending(delivery.id),
          );
        },
      ),
    );
  }
}
