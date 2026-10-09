import 'package:flutter/foundation.dart';

/// Liked place ids. Only kept in memory for now, so likes reset when the
/// app restarts. TODO: save with shared_preferences.
final likes = ValueNotifier<Set<String>>({});

void toggleLike(String placeId) {
  final next = {...likes.value};
  if (!next.remove(placeId)) next.add(placeId);
  likes.value = next;
}
