import 'package:flutter/material.dart';

import '../../../domain/model/patient.dart';
import '../../../domain/model/wound.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/photo_thumbnail.dart';

/// What a wound carries on its card beyond its name.
///
/// Read once per wound when the screen loads. It is the answer to "how is
/// this one doing", and without it the card is a label on a folder.
class WoundStanding {
  const WoundStanding({
    required this.visitCount,
    this.hasOpenVisit = false,
    this.areaCm2,
    this.areaChangeCm2,
    this.photoRef,
  });

  /// A wound nobody has visited yet.
  const WoundStanding.none()
    : visitCount = 0,
      hasOpenVisit = false,
      areaCm2 = null,
      areaChangeCm2 = null,
      photoRef = null;

  final int visitCount;

  /// Whether a visit for this wound was begun and never closed.
  ///
  /// The action then says so: "beginnen" would claim something starts that
  /// is already running, and the nurse would wonder what happened to the
  /// values she entered an hour ago.
  final bool hasOpenVisit;

  /// Length times width at the last visit, in square centimetres.
  ///
  /// Null when the last visit left either measurement out — a gap, not a
  /// zero.
  final double? areaCm2;

  /// The change against the visit before it; negative means smaller.
  final double? areaChangeCm2;

  /// Handle of the last photo, marked copy preferred.
  final String? photoRef;
}

/// One patient with the wounds kept for them.
///
/// The step between "who is in front of me" and "which wound am I dressing":
/// a patient with a heel and a lower leg has two courses, two photo series and
/// two reports, and a finding under the wrong heading is worse than none.
class PatientScreen extends StatelessWidget {
  const PatientScreen({
    required this.patient,
    required this.wounds,
    required this.standingOf,
    required this.loadPhoto,
    this.onOpenWound,
    this.onShowHistory,
    this.onAddWound,
    super.key,
  });

  final Patient patient;

  /// Open wounds first, newest first within each group.
  final List<Wound> wounds;

  /// How the wound is doing, for its card.
  final WoundStanding Function(Wound) standingOf;

  final PhotoLoader loadPhoto;

  final void Function(Wound)? onOpenWound;

  /// Opens the course of a wound without starting a visit.
  final void Function(Wound)? onShowHistory;

  final VoidCallback? onAddWound;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Where back goes, said in words: the arrow alone does not
            // distinguish "one step" from "out of the visit".
            Row(
              children: [
                const BackButton(),
                Expanded(
                  child: Text(
                    l10n.patientsTitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s16,
                spacing.s8,
                spacing.s16,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${patient.familyName}, ${patient.givenName}',
                    style: theme.textTheme.headlineMedium,
                  ),
                  SizedBox(height: spacing.s4),
                  // Birth date and address in one line: the first tells two
                  // people of the same name apart, the second is the place
                  // the nurse is standing in.
                  Text(
                    '${l10n.patientBirthDate(patient.birthDate)} · '
                    '${l10n.patientAddress(patient.street, patient.postalCode, patient.city)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: spacing.s24),
                  Text(
                    l10n.woundsHeading,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: wounds.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(spacing.s24),
                        child: Text(
                          l10n.woundsEmpty,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        spacing.s16,
                        spacing.s12,
                        spacing.s16,
                        spacing.s24,
                      ),
                      itemCount: wounds.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: spacing.s12),
                      itemBuilder: (context, index) {
                        final wound = wounds[index];
                        return _WoundCard(
                          wound: wound,
                          standing: standingOf(wound),
                          loadPhoto: loadPhoto,
                          onOpen: onOpenWound == null
                              ? null
                              : () => onOpenWound!(wound),
                          onShowHistory: onShowHistory == null
                              ? null
                              : () => onShowHistory!(wound),
                        );
                      },
                    ),
            ),
            if (onAddWound != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.s16,
                  0,
                  spacing.s16,
                  spacing.s16,
                ),
                child: OutlinedButton.icon(
                  onPressed: onAddWound,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.woundsAdd),
                  // Full width and quiet: adding a wound is the rarer of the
                  // two things done here, and the loud action sits on the
                  // card of the wound that is actually being dressed.
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(spacing.comfortTouch),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One wound with its state and the two things done to it.
class _WoundCard extends StatelessWidget {
  const _WoundCard({
    required this.wound,
    required this.standing,
    required this.loadPhoto,
    required this.onOpen,
    required this.onShowHistory,
  });

  final Wound wound;
  final WoundStanding standing;
  final PhotoLoader loadPhoto;
  final VoidCallback? onOpen;
  final VoidCallback? onShowHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(spacing.r12),
      ),
      padding: EdgeInsets.all(spacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhotoThumbnail(
                  ref: standing.photoRef,
                  loadPhoto: loadPhoto,
                  size: spacing.s64,
                  noPhotoLabel: l10n.woundNoPhoto,
                  missingLabel: l10n.woundPhotoMissing,
                ),
                SizedBox(width: spacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wound.location,
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: spacing.s4),
                      Text(
                        '${wound.isOpen ? l10n.woundOpenSince(wound.createdAt) : l10n.woundClosedOn(wound.closedAt!)} · '
                        '${l10n.woundVisitCount(standing.visitCount)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (wound.icd10Code != null) ...[
                        SizedBox(height: spacing.s4),
                        Text(
                          wound.icd10Code!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (standing.areaCm2 != null) ...[
            SizedBox(height: spacing.s16),
            _Area(
              areaCm2: standing.areaCm2!,
              changeCm2: standing.areaChangeCm2,
            ),
          ],
          if (onOpen != null || onShowHistory != null) ...[
            SizedBox(height: spacing.s16),
            _WoundActions(
              onOpen: wound.isOpen ? onOpen : null,
              onShowHistory: onShowHistory,
              resumes: standing.hasOpenVisit,
            ),
          ],
        ],
      ),
    );
  }
}

/// The figure the treatment is judged by, and which way it moved.
class _Area extends StatelessWidget {
  const _Area({required this.areaCm2, required this.changeCm2});

  final double areaCm2;
  final double? changeCm2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;
    final change = changeCm2;

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.historyArea(areaCm2),
            style: theme.textTheme.headlineMedium,
          ),
          if (change != null) ...[
            SizedBox(height: spacing.s4),
            Text(
              switch (change) {
                // Growth carries the same amber as "check": a wound getting
                // bigger is the finding that has to reach the office.
                > 0 => l10n.historyAreaIncrease(change),
                < 0 => l10n.historyAreaDecrease(-change),
                _ => l10n.historyAreaUnchanged,
              },
              style: theme.textTheme.labelSmall?.copyWith(
                color: change > 0
                    ? status.pruefen
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Beginning a visit, and looking at the course without beginning one.
class _WoundActions extends StatelessWidget {
  const _WoundActions({
    required this.onOpen,
    required this.onShowHistory,
    required this.resumes,
  });

  final VoidCallback? onOpen;
  final VoidCallback? onShowHistory;

  /// Whether the visit this leads into is already under way.
  final bool resumes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;

    // A healed wound has no visit to begin, but it keeps its course: that is
    // what a later question about this patient will be about.
    if (onOpen == null) {
      return OutlinedButton.icon(
        onPressed: onShowHistory,
        icon: const Icon(Icons.show_chart),
        label: Text(l10n.woundShowHistory),
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(spacing.comfortTouch),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.mic),
            label: Text(
              resumes ? l10n.woundResumeVisit : l10n.woundStartVisit,
            ),
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(spacing.comfortTouch),
            ),
          ),
        ),
        SizedBox(width: spacing.s8),
        // Square and quiet beside it: the course is read, the visit is
        // begun, and only one of the two is why the nurse is in the flat.
        SizedBox.square(
          dimension: spacing.comfortTouch,
          child: OutlinedButton(
            onPressed: onShowHistory,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.square(spacing.comfortTouch),
            ),
            child: Tooltip(
              message: l10n.woundShowHistory,
              child: const Icon(Icons.show_chart),
            ),
          ),
        ),
      ],
    );
  }
}
