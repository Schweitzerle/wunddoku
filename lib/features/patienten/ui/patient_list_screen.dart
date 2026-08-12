import 'package:flutter/material.dart';

import '../../../domain/model/patient.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import 'patient_list_view_model.dart';

/// The screen the app opens on: who is in front of me.
///
/// A visit belongs to a person and a wound, and everything downstream — the
/// course, the report, the deletion path — hangs off that. Starting anywhere
/// else would mean a finding without an owner.
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({
    required this.viewModel,
    required this.woundCount,
    this.onOpen,
    this.onAdd,
    super.key,
  });

  final PatientListViewModel viewModel;

  /// How many wounds are on file for a patient, for the second line.
  final int Function(Patient) woundCount;

  final void Function(Patient)? onOpen;
  final VoidCallback? onAdd;

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientsTitle)),
      floatingActionButton: widget.onAdd == null
          ? null
          : FloatingActionButton.extended(
              onPressed: widget.onAdd,
              icon: const Icon(Icons.person_add_outlined),
              label: Text(l10n.patientsAdd),
            ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) => Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.s16,
                  spacing.s8,
                  spacing.s16,
                  spacing.s8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: l10n.patientsSearch,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: widget.viewModel.searchFor,
                ),
              ),
              Expanded(child: _Body(screen: widget)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.screen});

  final PatientListScreen screen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final model = screen.viewModel;

    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.isEmpty || model.hasNoMatch) {
      return Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              model.isEmpty
                  ? l10n.patientsEmpty
                  : l10n.patientsNoMatch(model.query),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (model.isEmpty) ...[
              SizedBox(height: spacing.s8),
              Text(
                l10n.patientsEmptyHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: spacing.s24 * 3),
      itemCount: model.visible.length,
      itemBuilder: (context, index) {
        final patient = model.visible[index];
        return _PatientRow(
          patient: patient,
          woundCount: screen.woundCount(patient),
          onOpen: screen.onOpen == null
              ? null
              : () => screen.onOpen!(patient),
        );
      },
    );
  }
}

class _PatientRow extends StatelessWidget {
  const _PatientRow({
    required this.patient,
    required this.woundCount,
    required this.onOpen,
  });

  final Patient patient;
  final int woundCount;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return MergeSemantics(
      child: ListTile(
        onTap: onOpen,
        title: Text(
          '${patient.familyName}, ${patient.givenName}',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${l10n.patientBirthDate(patient.birthDate)} · '
          '${l10n.patientWoundCount(woundCount)}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
