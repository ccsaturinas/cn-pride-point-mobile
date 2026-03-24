import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/providers.dart';
import '../models/entities.dart';
import '../ui/cn_app_bar.dart';

class AttendeeDetailsPage extends ConsumerWidget {
  const AttendeeDetailsPage({
    super.key,
    required this.attendee,
    required this.yearLevelName,
    required this.sectionName,
  });

  final Attendee attendee;
  final String? yearLevelName;
  final String? sectionName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: cnAppBar(
        context: context,
        onLogout: () => ref.read(authSessionProvider.notifier).logout(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (attendee.displayName ?? '').trim().isEmpty
                    ? '${attendee.lastName ?? ''} ${attendee.firstName ?? ''}'
                        .trim()
                    : attendee.displayName!.trim(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _row('Type', attendee.attendeeType),
              _row('Gender', attendee.gender),
              _row('Year level', yearLevelName),
              _row('Section', sectionName),
              _row('Code', attendee.code),
              _row('Status', attendee.status),
              _row('Shirt size', attendee.shirtSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    final v = (value ?? '').trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text('$label:')),
          Expanded(child: Text(v.isEmpty ? '-' : v)),
        ],
      ),
    );
  }
}

