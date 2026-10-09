import 'package:flutter/material.dart';

import '../data/place.dart';
import '../widgets/place_tile.dart';

class PlacesScreen extends StatefulWidget {
  final List<Place> places;

  const PlacesScreen({super.key, required this.places});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  String _query = '';
  String? _type;

  @override
  Widget build(BuildContext context) {
    final results = widget.places.where((p) {
      if (_type != null && p.type != _type) return false;
      return p.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Places & Food')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search places',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final type in [null, ...placeTypes])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(type ?? 'All'),
                      selected: _type == type,
                      onSelected: (_) => setState(() => _type = type),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No places found.'))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, i) => PlaceTile(place: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
