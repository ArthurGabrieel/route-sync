import "package:flutter/material.dart";
import "package:core/core.dart";

import "../delivery_detail_viewmodel.dart";

class DeliveryActionButtons extends StatelessWidget {
  final DeliveryDetailViewModel viewModel;

  const DeliveryActionButtons({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;

    return Container(
      padding: 16.0.paddingAll,
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (vm.canStart)
            ListenableBuilder(
              listenable: vm.start,
              builder: (context, _) => _ActionButton(
                label: "Iniciar entrega",
                icon: Icons.directions_run,
                color: Colors.blue,
                loading: vm.start.value is RunningCommand,
                onPressed: vm.start.execute,
              ),
            ),
          if (vm.canConfirm) ...[
            ListenableBuilder(
              listenable: vm.confirm,
              builder: (context, _) => _ActionButton(
                label: "Confirmar entrega",
                icon: Icons.check_circle_outline,
                color: Colors.green,
                loading: vm.confirm.value is RunningCommand,
                onPressed: () => vm.confirm.execute(null),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (vm.canFail)
            ListenableBuilder(
              listenable: vm.fail,
              builder: (context, _) => _ActionButton(
                label: "Registrar falha",
                icon: Icons.cancel_outlined,
                color: Colors.red,
                loading: vm.fail.value is RunningCommand,
                onPressed: () => _showFailDialog(context, vm),
              ),
            ),
        ],
      ),
    );
  }

  void _showFailDialog(BuildContext context, DeliveryDetailViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FailBottomSheet(viewModel: vm),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: color),
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _FailBottomSheet extends StatefulWidget {
  final DeliveryDetailViewModel viewModel;

  const _FailBottomSheet({required this.viewModel});

  @override
  State<_FailBottomSheet> createState() => _FailBottomSheetState();
}

class _FailBottomSheetState extends State<_FailBottomSheet> {
  String? _selectedReason;
  final _notesController = TextEditingController();

  static const _reasons = [
    "Destinatário ausente",
    "Endereço não encontrado",
    "Recusa do destinatário",
    "Outro",
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: 16.0.paddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Motivo da falha",
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._reasons.map(
              (reason) => RadioGroup<String>(
                groupValue: _selectedReason,
                onChanged: (v) => setState(() => _selectedReason = v),
                child: Column(
                  children: _reasons
                      .map(
                        (reason) => RadioListTile<String>(
                          title: Text(reason),
                          value: reason,
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: "Observações (opcional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _selectedReason == null
                    ? null
                    : () {
                        Navigator.pop(context);
                        widget.viewModel.fail.execute((
                          reason: _selectedReason!,
                          notes: _notesController.text.isEmpty
                              ? null
                              : _notesController.text,
                        ));
                      },
                child: const Text("Confirmar falha"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
