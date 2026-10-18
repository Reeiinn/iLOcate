import 'package:flutter/material.dart';

import '../services/api_client.dart';

/// Error message with a retry button. Shows a "no connection" icon when the
/// error is an offline [ApiException].
class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final bool compact;

  const ErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offline = error is ApiException && (error as ApiException).isOffline;
    final icon = Icon(
      offline ? Icons.wifi_off : Icons.error_outline,
      color: theme.colorScheme.error,
      size: compact ? 28 : 56,
    );
    final message = Text(
      error.toString(),
      textAlign: compact ? TextAlign.start : TextAlign.center,
    );
    final retry = TextButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: const Text('Retry'),
    );

    if (compact) {
      return Row(children: [
        icon,
        const SizedBox(width: 12),
        Expanded(child: message),
        retry,
      ]);
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [icon, const SizedBox(height: 12), message, retry],
        ),
      ),
    );
  }
}
