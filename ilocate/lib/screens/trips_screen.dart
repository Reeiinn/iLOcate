import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trips_provider.dart';
import '../routes/app_router.dart';
import '../widgets/empty_state.dart';
import '../widgets/trip_card.dart';

/// List of the user's trip plans. Swipe a trip to delete it (with undo).
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  void _newTrip(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.tripForm);

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>().trips;

    return Scaffold(
      appBar: AppBar(title: const Text('My Trips')),
      body: trips.isEmpty
          ? EmptyState(
              icon: Icons.luggage_outlined,
              title: 'No trips planned',
              message: 'Group the places you want to visit into a trip, '
                  'then get directions between them.',
              actionLabel: 'Plan a trip',
              onAction: () => _newTrip(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 88),
              itemCount: trips.length,
              itemBuilder: (context, i) {
                final trip = trips[i];
                return Dismissible(
                  key: ValueKey(trip.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: const Icon(Icons.delete_outline),
                  ),
                  onDismissed: (_) {
                    final provider = context.read<TripsProvider>();
                    provider.delete(trip.id);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text('Deleted "${trip.title}"'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () => provider.restore(trip),
                        ),
                      ));
                  },
                  child: TripCard(
                    trip: trip,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.tripDetails,
                      arguments: trip.id,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new-trip',
        onPressed: () => _newTrip(context),
        icon: const Icon(Icons.add),
        label: const Text('New trip'),
      ),
    );
  }
}
