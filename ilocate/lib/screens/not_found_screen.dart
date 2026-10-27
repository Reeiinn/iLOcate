import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

/// Shown for an unknown route name or a route opened with the wrong argument.
class NotFoundScreen extends StatelessWidget {
  final String? routeName;

  const NotFoundScreen({super.key, this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.explore_off_outlined,
        title: 'Page not found',
        message: 'Nothing lives at "${routeName ?? '?'}".',
        actionLabel: 'Go back',
        onAction: () => Navigator.maybePop(context),
      ),
    );
  }
}
