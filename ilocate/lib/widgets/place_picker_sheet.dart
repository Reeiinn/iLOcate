import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/places_provider.dart';
import 'place_image.dart';

/// Bottom sheet for picking several places, with search. Returns the new
/// selection, or null if the user closes it without pressing Done.
Future<List<String>?> showPlacePicker(
  BuildContext context, {
  required List<String> selected,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PlacePickerSheet(initial: selected),
  );
}

class _PlacePickerSheet extends StatefulWidget {
  final List<String> initial;

  const _PlacePickerSheet({required this.initial});

  @override
  State<_PlacePickerSheet> createState() => _PlacePickerSheetState();
}

class _PlacePickerSheetState extends State<_PlacePickerSheet> {
  // A list, not a set, so places keep the order they were picked in.
  late final List<String> _selected = [...widget.initial];
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = context.read<PlacesProvider>().search(_query);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search places',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context, _selected),
                child: Text('Done (${_selected.length})'),
              ),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: results.length,
              itemBuilder: (context, i) {
                final place = results[i];
                return CheckboxListTile(
                  value: _selected.contains(place.id),
                  onChanged: (checked) => setState(() {
                    checked == true
                        ? _selected.add(place.id)
                        : _selected.remove(place.id);
                  }),
                  secondary: PlaceImage(place: place, width: 40, height: 40),
                  title: Text(place.name),
                  subtitle: Text(place.type),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
