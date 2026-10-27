import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/likes_provider.dart';

/// Heart toggle for a place. Only this button rebuilds when likes change,
/// thanks to context.select.
class LikeButton extends StatelessWidget {
  final String placeId;

  const LikeButton({super.key, required this.placeId});

  @override
  Widget build(BuildContext context) {
    final isLiked = context.select<LikesProvider, bool>(
      (likes) => likes.isLiked(placeId),
    );
    return IconButton(
      tooltip: isLiked ? 'Unlike' : 'Like',
      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
      color: isLiked ? Colors.red : null,
      onPressed: () => context.read<LikesProvider>().toggle(placeId),
    );
  }
}
