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
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Scaffold(
      // No app bar: at 56 dp fixed it cannot carry the 30 the title needs,
      // and the size contrast is what this palette has instead of colour.
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.s16,
                  spacing.s16,
                  spacing.s16,
                  spacing.s12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.patientsTitle,
                      style: theme.textTheme.headlineMedium,
                    ),
                    SizedBox(height: spacing.s12),
                    _SearchField(onChanged: widget.viewModel.searchFor),
                  ],
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

/// Finding a name, with gloves on.
///
/// Filled rather than outlined, and at least 56 dp tall: this is the one text
/// field on the screen, and an ordinary 40 dp box with a hairline border is
/// hard to hit and hard to see in daylight.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return TextField(
      onChanged: onChanged,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: l10n.patientsSearch,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
        constraints: BoxConstraints(minHeight: spacing.fieldRow),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.r12),
          borderSide: BorderSide.none,
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

    // Two groups only when there is something to separate: an unfinished
    // visit is work that has to end today, and it may not sit somewhere in
    // the alphabet.
    final rows = model.isGrouped
        ? <Object>[
            _Heading(l10n.patientsUnfinishedHeading(model.unfinished.length)),
            ...model.unfinished,
            _Heading(l10n.patientsRestHeading(model.rest.length)),
            ...model.rest,
          ]
        : <Object>[...model.visible];

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        spacing.s16,
        0,
        spacing.s16,
        // Room for the floating action to pass over the last row.
        spacing.s96,
      ),
      itemCount: rows.length,
      separatorBuilder: (context, index) => SizedBox(height: spacing.s8),
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row is _Heading) {
          return Padding(
            padding: EdgeInsets.only(top: spacing.s12, bottom: spacing.s4),
            child: Text(
              row.text,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final patient = row as Patient;
        return _PatientRow(
          patient: patient,
          woundCount: screen.woundCount(patient),
          hasOpenVisit: model.hasOpenVisit(patient),
          onOpen: screen.onOpen == null ? null : () => screen.onOpen!(patient),
        );
      },
    );
  }
}

/// A group heading in the list.
class _Heading {
  const _Heading(this.text);

  final String text;
}

/// One person, drawn as a card rather than as a list row.
///
/// The row is the target the nurse hits standing in a hallway with a bag in
/// one hand, so it carries a surface and 88 dp of height rather than a
/// divider and 48.
class _PatientRow extends StatelessWidget {
  const _PatientRow({
    required this.patient,
    required this.woundCount,
    required this.hasOpenVisit,
    required this.onOpen,
  });

  final Patient patient;
  final int woundCount;
  final bool hasOpenVisit;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    return MergeSemantics(
      // The open visit is marked on the edge as well as in words: the edge
      // is what carries across a list at arm's length, the words are what a
      // screen reader gets. Drawn as a border rather than as a child so the
      // list needs no intrinsic pass to make it full height.
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(spacing.r12),
          border: hasOpenVisit
              ? Border(
                  left: BorderSide(color: status.pruefen, width: spacing.s4),
                )
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onOpen,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: spacing.listCard),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(spacing.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${patient.familyName}, ${patient.givenName}',
                            style: theme.textTheme.titleMedium,
                          ),
                          SizedBox(height: spacing.s4),
                          Text(
                            '${l10n.patientBirthDate(patient.birthDate)} · '
                            '${l10n.patientWoundCount(woundCount)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (hasOpenVisit) ...[
                            SizedBox(height: spacing.s8),
                            const _OpenVisitBadge(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: spacing.s16),
                    child: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Says in words what the coloured edge says in colour.
class _OpenVisitBadge extends StatelessWidget {
  const _OpenVisitBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s8,
        vertical: spacing.s4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spacing.r8),
        border: Border.all(color: status.pruefen),
      ),
      child: Text(
        l10n.patientOpenVisitBadge,
        style: theme.textTheme.labelSmall?.copyWith(color: status.pruefen),
      ),
    );
  }
}
