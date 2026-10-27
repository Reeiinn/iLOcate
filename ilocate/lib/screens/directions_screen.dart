import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/directions_result.dart';
import '../models/place.dart';
import '../models/puj_route.dart';
import '../providers/location_provider.dart';
import '../providers/places_provider.dart';
import '../services/commute_planner.dart';
import '../services/directions_service.dart';
import '../widgets/error_view.dart';
import '../widgets/osm_tile_layer.dart';

/// Id used in the start dropdown for "my current GPS position".
const _myLocationId = '__my_location__';

/// Trip planner: pick a start and a destination, get the road route from
/// OSRM, and see which jeepney routes pass near both ends.
class DirectionsScreen extends StatefulWidget {
  final Place destination;

  /// Optional starting place, e.g. the previous stop of a trip.
  final Place? start;

  const DirectionsScreen({super.key, required this.destination, this.start});

  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  late Place _to = widget.destination;
  late String _fromId;
  late LatLng _fromPoint;
  late Future<DirectionsResult> _future;

  @override
  void initState() {
    super.initState();
    // Default start: the landmark closest to the city center, so the screen
    // shows a route right away. The user can switch to GPS or another place.
    final start = widget.start ?? _closestTo(iloiloCenter, except: _to.id);
    _fromId = start.id;
    _fromPoint = start.location;
    _future = _request();
  }

  Place _closestTo(LatLng point, {required String except}) {
    const distance = Distance();
    final places = context.read<PlacesProvider>().places;
    return places.where((p) => p.id != except).reduce((a, b) =>
        distance(point, a.location) <= distance(point, b.location) ? a : b);
  }

  Future<DirectionsResult> _request() =>
      context.read<DirectionsService>().fetchRoute(_fromPoint, _to.location);

  void _fetch() => setState(() => _future = _request());

  Future<void> _selectStart(String? id) async {
    if (id == null) return;
    if (id == _myLocationId) {
      final messenger = ScaffoldMessenger.of(context);
      final location = context.read<LocationProvider>();
      final previousId = _fromId;
      setState(() => _fromId = id);
      final point = await location.locate();
      if (!mounted) return;
      if (point == null) {
        // Keep the old start point and put the dropdown back to match it.
        setState(() => _fromId = previousId);
        messenger.showSnackBar(SnackBar(content: Text(location.error!)));
        return;
      }
      _fromPoint = point;
    } else {
      _fromId = id;
      _fromPoint = context.read<PlacesProvider>().placeById(id)!.location;
    }
    _fetch();
  }

  void _selectDestination(String? id) {
    final place =
        id == null ? null : context.read<PlacesProvider>().placeById(id);
    if (place == null) return;
    _to = place;
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<PlacesProvider>();
    final locating =
        context.select<LocationProvider, bool>((l) => l.isLocating);
    final sorted = [...data.places]..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(title: const Text('Directions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PlaceDropdown(
            label: 'From',
            icon: Icons.trip_origin,
            value: _fromId,
            places: sorted,
            includeMyLocation: true,
            onChanged: _selectStart,
          ),
          const SizedBox(height: 12),
          _PlaceDropdown(
            label: 'To',
            icon: Icons.place,
            value: _to.id,
            places: sorted,
            onChanged: _selectDestination,
          ),
          const SizedBox(height: 16),
          if (locating)
            const Center(child: Text('Finding your location...'))
          else
            FutureBuilder<DirectionsResult>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return ErrorView(error: snapshot.error!, onRetry: _fetch);
                }
                return _RouteView(
                  result: snapshot.data!,
                  from: _fromPoint,
                  to: _to,
                  jeepneys: jeepneysServing(
                    _fromPoint,
                    _to.location,
                    data.routes,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PlaceDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<Place> places;
  final bool includeMyLocation;
  final ValueChanged<String?> onChanged;

  const _PlaceDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.places,
    required this.onChanged,
    this.includeMyLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      // Key on the value so the text field updates when the selection
      // changes from code (e.g. after GPS fails).
      key: ValueKey(value),
      initialSelection: value,
      label: Text(label),
      leadingIcon: Icon(icon),
      expandedInsets: EdgeInsets.zero,
      enableFilter: true,
      requestFocusOnTap: true,
      menuHeight: 320,
      onSelected: onChanged,
      dropdownMenuEntries: [
        if (includeMyLocation)
          const DropdownMenuEntry(
            value: _myLocationId,
            label: 'My location',
            leadingIcon: Icon(Icons.my_location),
          ),
        for (final p in places) DropdownMenuEntry(value: p.id, label: p.name),
      ],
    );
  }
}

class _RouteView extends StatelessWidget {
  final DirectionsResult result;
  final LatLng from;
  final Place to;
  final List<PujRoute> jeepneys;

  const _RouteView({
    required this.result,
    required this.from,
    required this.to,
    required this.jeepneys,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points =
        result.points.length >= 2 ? result.points : [from, to.location];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 280,
            child: FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.coordinates(
                  coordinates: points,
                  padding: const EdgeInsets.all(40),
                ),
              ),
              children: [
                const OsmTileLayer(),
                PolylineLayer(polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: 5,
                    color: theme.colorScheme.primary,
                  ),
                ]),
                MarkerLayer(markers: [
                  Marker(
                    point: from,
                    child: Icon(Icons.trip_origin,
                        color: theme.colorScheme.primary),
                  ),
                  placeMarker(to.location, to.type, size: 36),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _Stat(
              icon: Icons.straighten,
              label: 'Distance',
              value: result.distanceLabel,
            ),
          ),
          Expanded(
            child: _Stat(
              icon: Icons.schedule,
              label: 'By car',
              value: result.durationLabel,
            ),
          ),
        ]),
        const SizedBox(height: 16),
        Text('Jeepneys that pass near both', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        if (jeepneys.isEmpty)
          Text(
            'No single jeepney route covers this trip. You may need to '
            'transfer, or take a tricycle or taxi.',
            style: theme.textTheme.bodySmall,
          )
        else
          for (final route in jeepneys.take(5))
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: CircleAvatar(radius: 10, backgroundColor: route.color),
              title: Text(route.number),
              subtitle: Text(route.name),
            ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      Icon(icon, color: theme.colorScheme.primary),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    ]);
  }
}
