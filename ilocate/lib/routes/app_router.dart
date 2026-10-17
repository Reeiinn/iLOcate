import 'package:flutter/material.dart';

import '../models/place.dart';
import '../screens/home_shell.dart';
import '../screens/not_found_screen.dart';
import '../screens/place_details_screen.dart';

/// Every named route in the app. Screens navigate with
/// `Navigator.pushNamed(context, AppRoutes.x, arguments: ...)`.
abstract final class AppRoutes {
  static const home = '/';
  static const placeDetails = '/place';
}

/// Builds the screen for a route name and checks its argument type, so a
/// wrong argument shows the "not found" page instead of crashing.
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  final Widget page = switch (settings.name) {
    AppRoutes.home => const HomeShell(),
    AppRoutes.placeDetails when args is Place =>
      PlaceDetailsScreen(place: args),
    _ => NotFoundScreen(routeName: settings.name),
  };
  return MaterialPageRoute(builder: (_) => page, settings: settings);
}
