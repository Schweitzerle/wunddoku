import 'package:flutter/material.dart';

import '../../../domain/model/image_marking.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import 'widgets/visit_chrome.dart';
import 'widgets/marking_editor.dart';

/// Marking the wound on the photo.
///
/// The briefing puts the wound picture in its own block rather than in a
/// finding card, and asks for the original *plus* a second file with the pen
/// mark burnt in. This screen produces the geometry both of those rest on.
class MarkingScreen extends StatefulWidget {
  const MarkingScreen({
    required this.photo,
    this.previous,
    this.initial,
    this.onDone,
    super.key,
  });

  final ImageProvider photo;

  /// The outline from the previous visit, drawn behind for comparison.
  final ImageMarking? previous;

  /// An outline being edited again rather than drawn from scratch.
  final ImageMarking? initial;

  final ValueChanged<ImageMarking>? onDone;

  @override
  State<MarkingScreen> createState() => _MarkingScreenState();
}

class _MarkingScreenState extends State<MarkingScreen> {
  late ImageMarking? _marking = widget.initial;
  MarkingTool _tool = MarkingTool.ellipse;

  bool get _hasOutline => (_marking?.outline.length ?? 0) > 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Marking belongs to the photo step; the band keeps saying so
            // while the nurse is drawing.
            Padding(
              padding: EdgeInsets.only(top: spacing.s8),
              child: Row(
                children: [
                  if (Navigator.of(context).canPop())
                    const BackButton()
                  else
                    SizedBox(width: spacing.s16),
                  Expanded(
                    child: Text(
                      l10n.markingTitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.s16),
                ],
              ),
            ),
            SizedBox(height: spacing.s8),
            const VisitBand(current: VisitStep.photo),
            SizedBox(height: spacing.s12),
            // What to do, only until it is being done. An instruction that
            // stays after the first mark is a line of the screen spent on
            // something nobody reads twice.
            if (!_hasOutline)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.s16,
                  0,
                  spacing.s16,
                  spacing.s12,
                ),
                child: Text(
                  l10n.markingHint,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            // Edge to edge, with undo and clear over the picture rather than
            // in a row of their own: the wound is what this screen is for.
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MarkingEditor(
                      photo: widget.photo,
                      marking: _marking,
                      previous: widget.previous,
                      tool: _tool,
                      onChanged: (marking) =>
                          setState(() => _marking = marking),
                    ),
                  ),
                  Positioned(
                    top: spacing.s8,
                    right: spacing.s8,
                    child: _OverlayActions(
                      onUndo: _marking == null || _marking!.outline.isEmpty
                          ? null
                          : () => setState(
                              () => _marking = _marking!.withoutLastPoint(),
                            ),
                      onClear: _marking == null
                          ? null
                          : () => setState(() => _marking = null),
                    ),
                  ),
                  if (widget.previous != null)
                    Positioned(
                      left: spacing.s8,
                      bottom: spacing.s8,
                      child: const _PreviousLegend(),
                    ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outline),
                ),
              ),
              child: SafeArea(
                top: false,
                minimum: EdgeInsets.all(spacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Toolbar(
                      tool: _tool,
                      onToolChanged: (tool) => setState(() => _tool = tool),
                    ),
                    SizedBox(height: spacing.s12),
                    FilledButton(
                      onPressed: _hasOutline
                          ? () => widget.onDone?.call(_marking!)
                          : null,
                      // The disabled button already says there is nothing to
                      // take over; a line of text under it said it again.
                      child: Text(l10n.markingDone),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Undo and clear, over the picture.
///
/// They belong to the drawing, not to a row of their own at the bottom: on
/// the image they are where the hand already is, and they give the tools
/// back the width they were squeezed out of.
class _OverlayActions extends StatelessWidget {
  const _OverlayActions({required this.onUndo, required this.onClear});

  final VoidCallback? onUndo;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;
    final status = context.statusColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        // Its own ground, because what is under it is a photograph: an icon
        // alone would sit on whatever colour the wound happens to have.
        color: status.mediaGround.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(spacing.r12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onUndo,
            icon: const Icon(Icons.undo),
            tooltip: l10n.markingUndo,
            color: status.onMediaGround,
            disabledColor: status.onMediaGround.withValues(alpha: 0.38),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.markingClear,
            color: status.onMediaGround,
            disabledColor: status.onMediaGround.withValues(alpha: 0.38),
          ),
        ],
      ),
    );
  }
}

/// Says what the second outline on the picture is.
///
/// A legend on the image rather than a sentence above it: the thing it
/// explains is right there, and a line of prose at the top of the screen was
/// read once and then cost its space for good.
class _PreviousLegend extends StatelessWidget {
  const _PreviousLegend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.mediaGround.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(spacing.r8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s8,
          vertical: spacing.s4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: spacing.s12,
              height: 3,
              color: status.markPrevious,
            ),
            SizedBox(width: spacing.s8),
            Text(
              l10n.markingPreviousVisit,
              style: theme.textTheme.labelSmall?.copyWith(
                color: status.onMediaGround,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tool choice plus undo and clear.
///
/// The three tools sit together because they are alternatives to each other:
/// dragging must never be the only way to draw (WCAG 2.2 SC 2.5.7), and with
/// gloves on an ellipse usually beats tracing an outline.
class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.tool, required this.onToolChanged});

  final MarkingTool tool;
  final ValueChanged<MarkingTool> onToolChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;

    final labels = {
      MarkingTool.ellipse: l10n.markingToolEllipse,
      MarkingTool.points: l10n.markingToolPoints,
      MarkingTool.freehand: l10n.markingToolFreehand,
    };
    final icons = {
      MarkingTool.ellipse: Icons.circle_outlined,
      MarkingTool.points: Icons.touch_app_outlined,
      MarkingTool.freehand: Icons.gesture,
    };

    // Three equal shares of one row: a Wrap put the third tool on a line of
    // its own and left undo and clear hanging beside it.
    return Row(
      children: [
        for (final (index, entry) in labels.entries.indexed) ...[
          if (index > 0) SizedBox(width: spacing.s8),
          Expanded(
            child: _ToolChip(
              label: entry.value,
              icon: icons[entry.key]!,
              selected: tool == entry.key,
              onTap: () => onToolChanged(entry.key),
            ),
          ),
        ],
      ],
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(spacing.r12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(spacing.r12),
          // Icon over label, not beside it: three tools sharing one row give
          // each a third of the width, and "Freihand" beside its icon did not
          // fit into a third of a narrow phone.
          child: Container(
            constraints: BoxConstraints(minHeight: spacing.comfortTouch),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s4,
              vertical: spacing.s8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
                SizedBox(height: spacing.s4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
