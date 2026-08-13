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
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s16,
                0,
                spacing.s16,
                spacing.s12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.markingHint,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (widget.previous != null) ...[
                    SizedBox(height: spacing.s4),
                    Text(
                      l10n.markingPreviousVisit,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFFF66EE),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s16),
                child: MarkingEditor(
                  photo: widget.photo,
                  marking: _marking,
                  previous: widget.previous,
                  tool: _tool,
                  onChanged: (marking) => setState(() => _marking = marking),
                ),
              ),
            ),
            _Toolbar(
              tool: _tool,
              onToolChanged: (tool) => setState(() => _tool = tool),
              onUndo: _marking == null || _marking!.outline.isEmpty
                  ? null
                  : () =>
                        setState(() => _marking = _marking!.withoutLastPoint()),
              onClear: _marking == null
                  ? null
                  : () => setState(() => _marking = null),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s16,
                0,
                spacing.s16,
                spacing.s16,
              ),
              child: Column(
                children: [
                  if (!_hasOutline) ...[
                    Text(
                      l10n.markingEmptyHint,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: spacing.s8),
                  ],
                  FilledButton(
                    onPressed: _hasOutline
                        ? () => widget.onDone?.call(_marking!)
                        : null,
                    child: Text(l10n.markingDone),
                  ),
                ],
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
  const _Toolbar({
    required this.tool,
    required this.onToolChanged,
    required this.onUndo,
    required this.onClear,
  });

  final MarkingTool tool;
  final ValueChanged<MarkingTool> onToolChanged;
  final VoidCallback? onUndo;
  final VoidCallback? onClear;

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

    return Padding(
      padding: EdgeInsets.all(spacing.s16),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: spacing.s8,
              children: [
                for (final entry in labels.entries)
                  _ToolChip(
                    label: entry.value,
                    icon: icons[entry.key]!,
                    selected: tool == entry.key,
                    onTap: () => onToolChanged(entry.key),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onUndo,
            icon: const Icon(Icons.undo),
            tooltip: l10n.markingUndo,
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.markingClear,
          ),
        ],
      ),
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
          child: Container(
            constraints: BoxConstraints(minHeight: spacing.minTouch),
            padding: EdgeInsets.symmetric(horizontal: spacing.s12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
                SizedBox(width: spacing.s8),
                Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
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
