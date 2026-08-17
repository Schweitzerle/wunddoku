import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../confirmation_view_model.dart';
import '../../../../shared/text/field_presentation.dart';

/// The gaps, collapsed into a single expandable row.
///
/// One row per unspoken field pushed everything else off the screen — with
/// eight finding cards the list would be unusable. A gap still has to be
/// visible, but it does not need the same space as a decision: it is
/// *information*, not *work*.
class GapZone extends StatefulWidget {
  const GapZone({required this.entries, super.key});

  final List<ConfirmationEntry> entries;

  @override
  State<GapZone> createState() => _GapZoneState();
}

class _GapZoneState extends State<GapZone> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    if (widget.entries.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.s12),
        child: Text(
          l10n.confirmationGapsNone,
          style: theme.textTheme.labelSmall?.copyWith(color: status.luecke),
        ),
      );
    }

    final names = widget.entries
        .map((e) => FieldPresentation.label(l10n, e.slotId))
        .join(' · ');

    return Semantics(
      label: '${l10n.confirmationGapsCollapsed(widget.entries.length)}: $names',
      button: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(spacing.r12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s16,
            vertical: spacing.s12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(spacing.r12),
            border: Border.all(color: status.luecke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.remove, size: 18, color: status.luecke),
                  SizedBox(width: spacing.s8),
                  Expanded(
                    child: Text(
                      l10n.confirmationGapsCollapsed(widget.entries.length),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (_expanded) ...[
                SizedBox(height: spacing.s8),
                Text(
                  names,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The values that go into the record as they stand, compactly.
///
/// Settled means "nothing to do here". It stays readable and reachable, but
/// it does not compete for attention with the rows that still need work.
class SettledZone extends StatelessWidget {
  const SettledZone({
    required this.entries,
    required this.onChange,
    super.key,
  });

  final List<ConfirmationEntry> entries;

  /// Called with the slot id of the row the nurse wants to change.
  ///
  /// A settled value used to be reachable only through the way back into the
  /// cards. It is part of the finding on this screen, so it is changed from
  /// this screen.
  final void Function(String slotId)? onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: theme.colorScheme.outlineVariant, height: spacing.s32),
        Padding(
          padding: EdgeInsets.only(bottom: spacing.s12),
          child: Text(
            l10n.confirmationSettledHeading(entries.length),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final entry in entries)
          _SettledRow(
            entry: entry,
            onTap: onChange == null ? null : () => onChange!(entry.slotId),
          ),
      ],
    );
  }
}

/// A value that is in the record, and the way to change it.
class _SettledRow extends StatelessWidget {
  const _SettledRow({required this.entry, required this.onTap});

  final ConfirmationEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final label = FieldPresentation.label(l10n, entry.slotId);
    final recorded = entry.recorded;
    final value = recorded != null
        ? FieldPresentation.storedValue(l10n, recorded)
        : FieldPresentation.value(l10n, entry.proposal!);

    return Semantics(
      label: '$label, $value',
      button: onTap != null,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(spacing.r8),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: spacing.minTouch),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: spacing.s12),
              Text(value, style: theme.textTheme.bodyLarge),
              if (onTap != null) ...[
                SizedBox(width: spacing.s4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
