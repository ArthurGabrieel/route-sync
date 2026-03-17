import "package:flutter/material.dart";

class PendingIndicator extends StatelessWidget {
  const PendingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.orange,
          ),
        ),
        SizedBox(width: 6),
        Text(
          "Sincronizando",
          style: TextStyle(fontSize: 12, color: Colors.orange),
        ),
      ],
    );
  }
}
