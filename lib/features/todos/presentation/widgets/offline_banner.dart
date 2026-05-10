import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;

  const OfflineBanner({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOffline ? 36 : 0,
      color: Colors.red.shade700,
      child: isOffline
          ? const Center(
              child: Text(
                'You are offline. Changes will sync when reconnected.',
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }
}
