import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../providers/places_provider.dart';
import '../providers/trips_provider.dart';
import '../routes/app_router.dart';
import '../widgets/place_image.dart';
import '../widgets/place_picker_sheet.dart';

/// Create or edit a trip. Validates the title, date, notes length and that
/// at least one place is picked before saving.
class TripFormScreen extends StatefulWidget {
  final TripFormArgs args;

  const TripFormScreen({super.key, required this.args});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  static const maxNotes = 300;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  DateTime? _date;
  late List<String> _placeIds;
  bool _saving = false;

  bool get _isEditing => widget.args.trip != null;

  @override
  void initState() {
    super.initState();
    final trip = widget.args.trip;
    _title = TextEditingController(text: trip?.title);
    _notes = TextEditingController(text: trip?.notes);
    _date = trip?.date;
    _placeIds = [
      ...?trip?.placeIds,
      if (widget.args.initialPlaceId != null) widget.args.initialPlaceId!,
    ];
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate(FormFieldState<DateTime> field) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 2),
    );
    if (picked == null) return;
    setState(() => _date = picked);
    field.didChange(picked);
  }

  Future<void> _pickPlaces(FormFieldState<List<String>> field) async {
    final picked = await showPlacePicker(context, selected: _placeIds);
    if (picked == null) return;
    setState(() => _placeIds = picked);
    field.didChange(picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final trips = context.read<TripsProvider>();
    final title = _title.text.trim();
    final notes = _notes.text.trim();
    final existing = widget.args.trip;
    if (existing != null) {
      await trips.update(existing.copyWith(
        title: title,
        date: _date,
        notes: notes,
        placeIds: _placeIds,
      ));
    } else {
      await trips.add(
        title: title,
        date: _date!,
        notes: notes,
        placeIds: _placeIds,
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Trip updated' : 'Trip saved')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final places = context.read<PlacesProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit trip' : 'New trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Trip name',
                hintText: 'e.g. Saturday food crawl in La Paz',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 40,
              validator: validateTripTitle,
            ),
            const SizedBox(height: 8),
            FormField<DateTime>(
              initialValue: _date,
              validator: (value) => value == null ? 'Pick a date' : null,
              builder: (field) => InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  errorText: field.errorText,
                  prefixIcon: const Icon(Icons.event),
                ),
                child: InkWell(
                  onTap: () => _pickDate(field),
                  child: Text(
                    _date == null
                        ? 'Tap to choose'
                        : DateFormat('EEE, MMM d, yyyy').format(_date!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Budget, who is coming, what to order...',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: maxNotes,
              validator: (value) => (value ?? '').trim().length > maxNotes
                  ? 'Keep notes under $maxNotes characters'
                  : null,
            ),
            const SizedBox(height: 8),
            FormField<List<String>>(
              initialValue: _placeIds,
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Add at least one place'
                  : null,
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('Places (${_placeIds.length})',
                        style: Theme.of(context).textTheme.titleSmall),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _pickPlaces(field),
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Choose'),
                    ),
                  ]),
                  if (field.hasError)
                    Text(
                      field.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  for (final place
                      in _placeIds.map(places.placeById).whereType<Place>())
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: PlaceImage(place: place, width: 40, height: 40),
                      title: Text(place.name),
                      trailing: IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() => _placeIds = [
                                for (final id in _placeIds)
                                  if (id != place.id) id,
                              ]);
                          field.didChange(_placeIds);
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Save changes' : 'Save trip'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trip names must have 3 to 40 visible characters. Top-level so it can be
/// unit tested without building the form.
String? validateTripTitle(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return 'Give the trip a name';
  if (text.length < 3) return 'Name must be at least 3 characters';
  if (text.length > 40) return 'Name must be 40 characters or less';
  return null;
}
