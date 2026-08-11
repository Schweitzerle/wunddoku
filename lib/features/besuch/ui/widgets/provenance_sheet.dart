import 'package:flutter/material.dart';

import '../../../../domain/capture/field_proposal.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';

/// Shows the passage of the verbatim transcript a value was taken from.
///
/// This is the answer to "why should I believe that number" (JS-4): the nurse
/// sees her own words with the relevant part highlighted, instead of having to
/// trust a printed value.
class ProvenanceSheet extends StatelessWidget {
  const ProvenanceSheet({
    required this.transcript,
    required this.span,
    super.key,
  });

  final String transcript;

  /// The highlighted passage, or null when the field carries no value.
  final TranscriptSpan? span;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.provenanceTitle, style: theme.textTheme.titleMedium),
            SizedBox(height: spacing.s8),
            Text(
              l10n.provenanceHint,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.s16),
            // A long dictation must scroll rather than push the close button
            // off the sheet — the transcript has no length limit.
            Flexible(
              child: SingleChildScrollView(
                child: Semantics(
                  // Read out as one node, otherwise the screen reader
                  // announces three fragments and the sentence falls apart.
                  label: transcript,
                  excludeSemantics: true,
                  child: Text.rich(
                    _highlighted(theme, status.pruefen),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _highlighted(ThemeData theme, Color accent) {
    final highlight = span;
    if (highlight == null || highlight.end > transcript.length) {
      return TextSpan(text: transcript);
    }
    return TextSpan(
      children: [
        TextSpan(text: transcript.substring(0, highlight.start)),
        TextSpan(
          text: transcript.substring(highlight.start, highlight.end),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            backgroundColor: accent.withValues(alpha: 0.25),
          ),
        ),
        TextSpan(text: transcript.substring(highlight.end)),
      ],
    );
  }
}
