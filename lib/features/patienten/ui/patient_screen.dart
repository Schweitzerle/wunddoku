import 'package:flutter/material.dart';

import '../../../domain/model/patient.dart';
import '../../../domain/model/wound.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

/// One patient with the wounds kept for them.
///
/// The step between "who is in front of me" and "which wound am I dressing":
/// a patient with a heel and a lower leg has two courses, two photo series and
/// two reports, and a finding under the wrong heading is worse than none.
class PatientScreen extends StatelessWidget {
  const PatientScreen({
    required this.patient,
    required this.wounds,
    required this.visitCount,
    this.onOpenWound,
    this.onAddWound,
    super.key,
  });

  final Patient patient;

  /// Open wounds first, newest first within each group.
  final List<Wound> wounds;

  /// How many visits are documented for a wound.
  final int Function(Wound) visitCount;

  final void Function(Wound)? onOpenWound;
  final VoidCallback? onAddWound;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.familyName}, ${patient.givenName}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(
              left: spacing.s16,
              right: spacing.s16,
              bottom: spacing.s8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.patientBirthDate(patient.birthDate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: onAddWound == null
          ? null
          : FloatingActionButton.extended(
              onPressed: onAddWound,
              icon: const Icon(Icons.add),
              label: Text(l10n.woundsAdd),
            ),
      body: SafeArea(
        child: wounds.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(spacing.s24),
                  child: Text(
                    l10n.woundsEmpty,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  spacing.s16,
                  spacing.s8,
                  spacing.s16,
                  spacing.s24 * 3,
                ),
                itemCount: wounds.length,
                itemBuilder: (context, index) {
                  final wound = wounds[index];
                  return _WoundCard(
                    wound: wound,
                    visits: visitCount(wound),
                    onOpen: onOpenWound == null
                        ? null
                        : () => onOpenWound!(wound),
                  );
                },
              ),
      ),
    );
  }
}

class _WoundCard extends StatelessWidget {
  const _WoundCard({
    required this.wound,
    required this.visits,
    required this.onOpen,
  });

  final Wound wound;
  final int visits;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return MergeSemantics(
      child: Card(
        margin: EdgeInsets.only(bottom: spacing.s12),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(spacing.r12),
          child: Padding(
            padding: EdgeInsets.all(spacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wound.location, style: theme.textTheme.titleMedium),
                SizedBox(height: spacing.s4),
                Text(
                  wound.isOpen
                      ? l10n.woundOpenSince(wound.createdAt)
                      : l10n.woundClosedOn(wound.closedAt!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  l10n.woundVisitCount(visits),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (wound.icd10Code != null) ...[
                  SizedBox(height: spacing.s4),
                  Text(wound.icd10Code!, style: theme.textTheme.labelMedium),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
