import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/place.dart';
import '../data/puj_route.dart';
import 'place_details_screen.dart';

const iloiloCenter = LatLng(10.7202, 122.5621);

class MapScreen extends StatefulWidget {
  final List<Place> places;
  final List<PujRoute> routes;

  const MapScreen({super.key, required this.places, required this.routes});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<String> _shownRoutes = {};
  bool _showPlaces = true;

  List<Polyline> get _polylines {
    final lines = <Polyline>[];
    for (final route in widget.routes) {
      if (!_shownRoutes.contains(route.number)) continue;
      for (final points in [route.goingTo, route.goingBack]) {
        if (points.length < 2) continue;
        lines.add(Polyline(points: points, color: route.color, strokeWidth: 4));
      }
    }
    return lines;
  }

  void _openRoutePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void toggle(String number) {
            setState(() {
              if (!_shownRoutes.remove(number)) _shownRoutes.add(number);
            });
            setSheetState(() {});
          }

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            builder: (context, controller) => Column(
              children: [
                ListTile(
                  title: const Text('Jeepney routes', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: TextButton(
                    onPressed: _shownRoutes.isEmpty
                        ? null
                        : () {
                            setState(_shownRoutes.clear);
                            setSheetState(() {});
                          },
                    child: const Text('Clear'),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      for (final route in widget.routes)
                        CheckboxListTile(
                          value: _shownRoutes.contains(route.number),
                          onChanged: (_) => toggle(route.number),
                          secondary: CircleAvatar(radius: 8, backgroundColor: route.color),
                          title: Text(route.number),
                          subtitle: Text(route.name),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPlacePreview(Place place) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(place.image, width: 64, height: 64, fit: BoxFit.cover),
        ),
        title: Text(place.name),
        subtitle: Text(place.type),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pop(sheetContext);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlaceDetailsScreen(place: place)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('iLOcate'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _showPlaces ? 'Hide places' : 'Show places',
            icon: Icon(_showPlaces ? Icons.location_on : Icons.location_off),
            onPressed: () => setState(() => _showPlaces = !_showPlaces),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: iloiloCenter, initialZoom: 13.5),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.reeiinn.ilocate',
          ),
          PolylineLayer(polylines: _polylines),
          if (_showPlaces)
            MarkerLayer(
              markers: [
                for (final place in widget.places)
                  Marker(
                    point: place.location,
                    width: 28,
                    height: 28,
                    child: GestureDetector(
                      onTap: () => _showPlacePreview(place),
                      child: Icon(Icons.location_on, color: colorForType(place.type), size: 28),
                    ),
                  ),
              ],
            ),
          const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRoutePicker,
        icon: const Icon(Icons.directions_bus),
        label: Text(_shownRoutes.isEmpty ? 'Routes' : 'Routes (${_shownRoutes.length})'),
      ),
    );
  }
}
