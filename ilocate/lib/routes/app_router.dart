import 'package:flutter/material.dart';

import '../models/place.dart';
import '../models/trip.dart';
import '../screens/directions_screen.dart';
import '../screens/home_shell.dart';
import '../screens/not_found_screen.dart';
import '../screens/place_details_screen.dart';
import '../screens/trip_details_screen.dart';
import '../screens/trip_form_screen.dart';

/// Every named route in the app. Screens navigate with
/// `Navigator.pushNamed(context, AppRoutes.x, arguments: ...)`.
abstract final class AppRoutes {
  static const home = '/';
  static const placeDetails = '/place';
  static const directions = '/directions';
  static const tripDetails = '/trip';
  static const tripForm = '/trip/form';
}

/// Arguments for [AppRoutes.directions]. A bare [Place] also works and means
/// "directions to this place from the default start".
class DirectionsArgs {
  final Place to;
  final Place? from;

  const DirectionsArgs({required this.to, this.from});
}

/// Arguments for [AppRoutes.tripForm]. Pass [trip] to edit an existing trip,
/// or leave it null to create one (optionally starting with [initialPlaceId]).
class TripFormArgs {
  final Trip? trip;
  final String? initialPlaceId;

  const TripFormArgs({this.trip, this.initialPlaceId});
}

/// Builds the screen for a route name and checks its argument type, so a
/// wrong argument shows the "not found" page instead of crashing.
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  final Widget page = switch (settings.name) {
    AppRoutes.home => const HomeShell(),
    AppRoutes.placeDetails when args is Place =>
      PlaceDetailsScreen(place: args),
    AppRoutes.directions when args is Place =>
      DirectionsScreen(destination: args),
    AppRoutes.directions when args is DirectionsArgs =>
      DirectionsScreen(destination: args.to, start: args.from),
    AppRoutes.tripDetails when args is String =>
      TripDetailsScreen(tripId: args),
    AppRoutes.tripForm => TripFormScreen(
        args: args is TripFormArgs ? args : const TripFormArgs(),
      ),
    _ => NotFoundScreen(routeName: settings.name),
  };
  return MaterialPageRoute(builder: (_) => page, settings: settings);
}
