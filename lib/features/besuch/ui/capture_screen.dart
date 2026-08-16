import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/model/visit_standing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import 'capture_view_model.dart';
import 'widgets/level_meter.dart';
import 'widgets/visit_chrome.dart';

/// Phase A of the visit: the finding is spoken while the dressing is open.
///
/// This is the screen the nurse does not look at. Both hands are busy and the
/// eyes are on the wound, so the layout is built around one large target in
/// the lower reach area, and the feedback that matters — the microphone being
/// open — is carried by sound, vibration *and* sight at once.
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({
    required this.viewModel,
    this.context,
    this.visitDate,
    this.standing = const VisitStanding.empty(),
    this.onInterpreted,
    this.onUseCards,
    this.onTakePhoto,
    this.onFinishVisit,
    this.onShowHistory,
    this.onSelectStep,
    super.key,
  });

  final CaptureViewModel viewModel;

  /// Whose wound is being documented, for the second line of the header.
  final String? context;

  /// When the open visit was started, for the visit header.
  final DateTime? visitDate;

  /// What the visit already holds.
  ///
  /// Shown instead of the examples once there is anything to show: the record
  /// is the re-entry point after an interruption, and a screen that looks
  /// freshly started tells the nurse nothing about where she left off.
  final VisitStanding standing;

  /// Called when a recording has been turned into field proposals.
  final VoidCallback? onInterpreted;

  /// Called for the equal path without speech.
  final VoidCallback? onUseCards;

  /// Called to show the visits recorded so far.
  final VoidCallback? onShowHistory;

  /// Called to close the visit.
  ///
  /// In the app bar rather than among the capture actions: closing ends the
  /// visit and must be reachable from every step, but it must never sit where
  /// a thumb goes for the recording.
  final VoidCallback? onFinishVisit;

  /// Called to photograph the wound.
  ///
  /// Sits in phase A next to the recording: both happen at the open dressing,
  /// and the photo is worthless once the new bandage is on.
  final VoidCallback? onTakePhoto;

  /// Called with the step of the visit the nurse tapped in the band.
  final void Function(VisitStep step)? onSelectStep;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (widget.viewModel.state is CaptureDone) {
      widget.onInterpreted?.call();
    }
  }

  Future<void> _toggleRecording() async {
    _confirmByTouch();
    if (widget.viewModel.isRecording) {
      await widget.viewModel.stopRecording();
    } else {
      await widget.viewModel.startRecording();
    }
  }

  /// Confirms start and stop through the hand.
  ///
  /// In a stranger's flat the nurse must be able to tell that the microphone
  /// closed without looking. Deliberately not awaited and failure-tolerant: a
  /// device without a vibrator must still be able to record.
  void _confirmByTouch() {
    unawaited(HapticFeedback.mediumImpact().catchError((_) {}));
  }

  @override
  Widget build(BuildContext context) {
    final context_ = widget.context;

    // The chrome of the visit, not of this screen: the band answers "where am
    // I" on every step, so it is handed to each state rather than drawn once
    // around them — the recording is the one state that drops it.
    final header = VisitHeader(
      step: VisitStep.speak,
      visitDate: widget.visitDate,
      onBack: Navigator.of(context).canPop()
          ? () => Navigator.of(context).maybePop()
          : null,
      onFinish: widget.onFinishVisit,
      onSelectStep: widget.onSelectStep,
    );

    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => switch (widget.viewModel.state) {
          CaptureUnavailable() => _NoMicrophone(
            header: header,
            onUseCards: widget.onUseCards,
          ),
          CaptureQueued() => _Queued(
            header: header,
            onUseCards: widget.onUseCards,
          ),
          CaptureInterpreting() => const _Interpreting(),
          final CaptureRecording state => _Recording(
            header: header,
            state: state,
            onStop: _toggleRecording,
          ),
          _ => _Idle(
            header: header,
            address: context_,
            standing: widget.standing,
            onStart: _toggleRecording,
            onUseCards: widget.onUseCards,
            onTakePhoto: widget.onTakePhoto,
            onShowHistory: widget.onShowHistory,
          ),
        },
      ),
    );
  }
}

/// Shared frame for the capture states: scrollable content, one large action
/// pinned to the lower reach area.
///
/// The action stays put while the text above scrolls, so it is in the same
/// place at every text size — at 200 % the explanation grows, the button does
/// not move.
class _CaptureLayout extends StatelessWidget {
  const _CaptureLayout({
    required this.children,
    required this.action,
    this.header,
    this.ways = const [],
  });

  final List<Widget> children;
  final Widget action;

  /// The visit header and band, where this state carries them.
  final Widget? header;

  /// The equal paths: icon, the word on the tile, the sentence a screen
  /// reader gets, and what to do.
  final List<(IconData, String, String, VoidCallback?)> ways;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Three across is the layout while three labels fit across. Beyond
          // that they break mid-word ("Verla / uf"), so the paths become a
          // list and move out of the thumb zone into the reading matter: at
          // twice the text size the surface is scarce, and what must not move
          // is the one target the nurse hits without looking.
          final across = _WayTiles.fitAcross(
            context: context,
            ways: ways,
            available: constraints.maxWidth - 2 * spacing.s16,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?header,
              // Reading fills from the top, the paths sit low where the thumb
              // is, and the gap between them lands between two groups rather
              // than at the end of the screen. On a real phone that
              // end-of-screen hole was the largest thing on it.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, viewport) {
                    final padding = EdgeInsets.fromLTRB(
                      spacing.s16,
                      spacing.s24,
                      spacing.s16,
                      spacing.s24,
                    );

                    return SingleChildScrollView(
                      padding: padding,
                      child: ConstrainedBox(
                        // The content fills the viewport even when it is
                        // shorter, so a [Spacer] among the children turns
                        // what used to be dead space at the bottom into the
                        // gap between two groups. Costs one intrinsic pass
                        // over a handful of leaves; this is a screen, not a
                        // list (`25-performance.md`).
                        constraints: BoxConstraints(
                          minHeight: viewport.maxHeight - padding.vertical,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...children,
                              if (ways.isNotEmpty && !across) ...[
                                SizedBox(height: spacing.s24),
                                _WayTiles(ways: ways, across: false),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // What is touched sits low and does not scroll away: the one
              // large target keeps the same place at every text size, so the
              // thumb finds it without looking.
              _Dock(
                ways: ways.isNotEmpty && across
                    ? _WayTiles(ways: ways, across: true)
                    : null,
                action: action,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The area the thumb owns: the equal paths, then the one large action.
class _Dock extends StatelessWidget {
  const _Dock({required this.ways, required this.action});

  final Widget? ways;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        // A line, not a tone: the two surfaces are 1.09:1 apart, which is
        // present indoors and absent in sunlight — and the standing card
        // above carries the same fill, so without the line the two ran into
        // each other at 200 % text. The outline is 3.4:1 on the surface.
        // Square, because this is a fixed bar and a rounded top edge claims
        // a sheet that floats over something. Nothing floats here.
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      padding: EdgeInsets.all(spacing.s16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ways != null) ...[ways!, SizedBox(height: spacing.s12)],
          action,
        ],
      ),
    );
  }
}

/// The one target on this screen, sized to be hit without looking.
///
/// Twice the height of an ordinary button: the nurse presses it with gloves
/// on, eyes on the wound. Everything else here can be missed; this cannot.
class _PrimaryCaptureAction extends StatelessWidget {
  const _PrimaryCaptureAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    // The size goes through the button style, not through the Text: a
    // TextStyle taken from ThemeData carries onSurface as its colour, and
    // handing it to a filled button would override the button's onPrimary
    // and quietly drop the label below the contrast floor.
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: Size.fromHeight(spacing.s96),
        // 22 rather than 20, which keeps the recording state to the four
        // type sizes the rules allow and gives the one target a label to
        // match its size.
        textStyle: theme.textTheme.headlineSmall,
      ),
      icon: Icon(icon, size: 28),
      label: Text(label),
    );
  }
}

class _Idle extends StatelessWidget {
  const _Idle({
    required this.header,
    required this.address,
    required this.standing,
    required this.onStart,
    required this.onUseCards,
    required this.onTakePhoto,
    required this.onShowHistory,
  });

  final Widget header;

  /// Whose wound is open in front of the nurse.
  final String? address;

  final VisitStanding standing;

  final VoidCallback onStart;

  /// The path without speech, offered here and not only after a refusal.
  ///
  /// Speech is the shortcut, never the only way (`23-a11y.md`): the patient
  /// may not want to be recorded, the room may be too loud, or three taps may
  /// simply be faster than a sentence.
  final VoidCallback? onUseCards;

  /// Photographing the wound, the other half of phase A.
  final VoidCallback? onTakePhoto;

  /// The course so far.
  ///
  /// Reachable before the recording on purpose: what the wound looked like a
  /// week ago is what the nurse compares against while the dressing is off.
  final VoidCallback? onShowHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return _CaptureLayout(
      header: header,
      action: _PrimaryCaptureAction(
        icon: Icons.mic,
        label: l10n.captureStart,
        onPressed: onStart,
      ),
      ways: [
        (
          Icons.checklist,
          l10n.captureWayCards,
          l10n.captureUseCards,
          onUseCards,
        ),
        (
          Icons.photo_camera_outlined,
          l10n.captureWayPhoto,
          l10n.captureTakePhoto,
          onTakePhoto,
        ),
        (
          Icons.show_chart,
          l10n.captureWayHistory,
          l10n.captureShowHistory,
          onShowHistory,
        ),
      ],
      children: [
        // Whose wound this is, in the body rather than in the app bar: at the
        // text sizes people actually run their phones at, a second line up
        // there collides with the title and the action.
        Text(l10n.captureTitle, style: theme.textTheme.headlineMedium),
        if (address != null) ...[
          SizedBox(height: spacing.s4),
          _Address(text: address!),
        ],
        SizedBox(height: spacing.s24),
        // On a visit under way the standing leads: the first thing a nurse
        // coming back from an interruption needs is where she left off.
        if (!standing.isEmpty) ...[
          _StandingCard(standing: standing),
          SizedBox(height: spacing.s24),
        ],
        _Hint(text: l10n.captureIdleHint),
        // Whatever room is left over lands here rather than at the bottom of
        // the screen: the examples then stand a constant 24 dp above the
        // thumb zone, next to the button they describe, at every fill level.
        // When the content is taller than the viewport this collapses to
        // nothing and the screen simply scrolls.
        const Spacer(),
        SizedBox(height: spacing.s24),
        Text(
          l10n.captureExamplesHeading,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        // Inside the group half of what separates the groups: spacing is
        // the cheapest grouping there is, and equal padding everywhere is
        // a surface without structure (`22-design-tokens.md`).
        SizedBox(height: spacing.s8),
        _Example(text: l10n.captureExampleOne),
        SizedBox(height: spacing.s8),
        _Example(text: l10n.captureExampleTwo),
      ],
    );
  }
}

/// Whose wound this visit documents.
///
/// The subtitle of the screen title, without an icon in front of it: the
/// figure marked "who" and then truncated the location it was there to
/// introduce. Wrapping onto a second line costs a line; losing the end of
/// "linker Unterschenkel, distal" costs the half that says *which* wound.
class _Address extends StatelessWidget {
  const _Address({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// The instruction, kept to the weight of an aside.
///
/// It explains the button underneath and nothing else, so it may not carry
/// the same weight as the record above it.
class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: spacing.s8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// The three equal paths, side by side and the same size.
///
/// `standardfallen.md` names "three equal tiles in a row" as a model
/// preference, and it is one — but cards, photo and course really are equal
/// ways into the same record rather than a ranking, so the exception applies
/// (`docs/design/README.md`). As a list under the microphone they read as
/// footnotes to speech, which is exactly what they are not.
class _WayTiles extends StatelessWidget {
  const _WayTiles({required this.ways, required this.across});

  /// Icon, the word on the tile, the full sentence a screen reader gets, and
  /// what to do.
  final List<(IconData, String, String, VoidCallback?)> ways;

  /// Whether the tiles stand side by side rather than under each other.
  final bool across;

  /// Whether the labels of [ways] fit side by side in [available].
  ///
  /// Measured rather than derived from the text scale: the answer depends on
  /// the width as much as on the size, and a threshold picked from arithmetic
  /// would be wrong on the first phone that is not the one it was picked on.
  static bool fitAcross({
    required BuildContext context,
    required List<(IconData, String, String, VoidCallback?)> ways,
    required double available,
  }) {
    if (ways.isEmpty) return true;

    final spacing = context.spacing;
    final style = Theme.of(context).textTheme.labelSmall;
    final scaler = MediaQuery.textScalerOf(context);
    final tileWidth =
        (available - spacing.s8 * (ways.length - 1)) / ways.length;

    for (final way in ways) {
      final painter = TextPainter(
        text: TextSpan(text: way.$2, style: style),
        textDirection: Directionality.of(context),
        textScaler: scaler,
      )..layout();
      final needed = painter.width + 2 * spacing.s8;
      painter.dispose();
      if (needed > tileWidth) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    final tiles = [
      for (final way in ways)
        _WayTile(
          icon: way.$1,
          label: way.$2,
          semanticsLabel: way.$3,
          onTap: way.$4,
          across: across,
        ),
    ];

    if (!across) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, tile) in tiles.indexed) ...[
            if (index > 0) SizedBox(height: spacing.s8),
            tile,
          ],
        ],
      );
    }

    // Equal height even when one label wraps and the others do not: three
    // leaf tiles are cheap to measure, and tiles of different heights would
    // undo the very thing the row is here to say.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, tile) in tiles.indexed) ...[
            if (index > 0) SizedBox(width: spacing.s8),
            Expanded(child: tile),
          ],
        ],
      ),
    );
  }
}

/// An equal path, drawn as something you press.
///
/// Speech is the shortcut, never the only way (`23-a11y.md`). The word on the
/// tile is short because three of them share a phone width; the sentence a
/// screen reader reads out is the full one.
class _WayTile extends StatefulWidget {
  const _WayTile({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.onTap,
    required this.across,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final VoidCallback? onTap;

  /// Whether the label sits under the icon rather than beside it.
  final bool across;

  @override
  State<_WayTile> createState() => _WayTileState();
}

class _WayTileState extends State<_WayTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final icon = widget.icon;
    final across = widget.across;
    final onTap = widget.onTap;
    final enabled = onTap != null;
    final foreground = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    final glyph = Icon(icon, size: 22, color: foreground);
    final text = ExcludeSemantics(
      child: Text(
        widget.label,
        textAlign: across ? TextAlign.center : TextAlign.start,
        style: theme.textTheme.labelSmall?.copyWith(color: foreground),
      ),
    );

    return Semantics(
      label: widget.semanticsLabel,
      child: Material(
        color: theme.colorScheme.surface,
        // An outline, not a lighter fill: in this palette no two surface
        // tones are more than 1.2:1 apart, so a tinted panel says "target"
        // indoors and nothing at all in sunlight. The outline clears the 3:1
        // that a control boundary owes (`23-a11y.md`).
        //
        // Focus moves the same edge rather than adding Material's tinted
        // overlay — for the same reason: the default overlay changes the
        // fill by about 1.1:1 here and is not an indicator anyone can see.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.r12),
          side: BorderSide(
            color: _focused
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: _focused ? 3 : 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: spacing.s64),
            child: Padding(
              padding: EdgeInsets.all(spacing.s8),
              child: across
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [glyph, SizedBox(height: spacing.s4), text],
                    )
                  : Row(
                      children: [
                        SizedBox(width: spacing.s8),
                        glyph,
                        SizedBox(width: spacing.s16),
                        Expanded(child: text),
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onSurfaceVariant,
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

/// The visit at a glance: three numbers, largest first.
///
/// Replaces three sentences of running text. What the nurse wants on return
/// is not prose but the answer to "how far am I" — and the one figure that
/// decides whether she can leave the flat is what is still missing.
class _StandingCard extends StatelessWidget {
  const _StandingCard({required this.standing});

  final VisitStanding standing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;
    final complete = standing.gapCount == 0;

    return MergeSemantics(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(spacing.r12),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Metric(
              value: '${standing.valueCount}',
              label: l10n.captureMetricValues,
            ),
            // At twice the text size the three labels grow into each other
            // without it, and "Werte Fotos fehlen" reads as one line.
            SizedBox(width: spacing.s8),
            _Metric(
              value: '${standing.photoCount}',
              label: l10n.captureMetricPhotos,
              // A drawn tick, not the character: the bundled font has no
              // check mark and would print an empty box.
              badge: standing.markedPhotoCount > 0 ? Icons.check : null,
            ),
            SizedBox(width: spacing.s8),
            _Metric(
              value: complete ? '' : '${standing.gapCount}',
              badge: complete ? Icons.check_circle : null,
              label: complete
                  ? l10n.captureMetricComplete
                  : l10n.captureMetricGaps,
              // The only figure that decides whether the visit can be left
              // as it is — so it is the only one that carries colour.
              colour: complete ? status.sicher : status.pruefen,
              emphasised: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    this.colour,
    this.badge,
    this.emphasised = false,
  });

  final String value;
  final String label;
  final Color? colour;

  /// Drawn beside the figure when there is something to add to it.
  final IconData? badge;

  /// Whether this figure is the one that decides.
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (value.isNotEmpty)
                Text(
                  value,
                  // All three figures are the same size. A larger one sat on
                  // a lower baseline, so its label hung 4 dp below the other
                  // two and the card's bottom edge frayed — and it was a
                  // fifth type size on a screen the rules allow four on.
                  // The emphasis is carried by colour and by the icon.
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colour ?? theme.colorScheme.onSurface,
                  ),
                ),
              if (badge != null) ...[
                if (value.isNotEmpty) SizedBox(width: spacing.s4),
                Icon(
                  badge,
                  size: emphasised ? 28 : 20,
                  color: colour ?? theme.colorScheme.onSurface,
                ),
              ],
            ],
          ),
          SizedBox(height: spacing.s4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Example extends StatelessWidget {
  const _Example({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    // A spoken sentence, set as one: the border on the speaking side rather
    // than a box all around, so it reads as a quotation and not as another
    // card to press. In the outline colour, not the accent — the rule is one
    // accent per screen, and these two rules carry neither an action nor a
    // state.
    return Container(
      padding: EdgeInsets.fromLTRB(
        spacing.s12,
        spacing.s8,
        spacing.s12,
        spacing.s8,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.colorScheme.outline, width: 3),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

/// The microphone is open.
///
/// The state the nurse is actually in, and the one the patient sitting beside
/// her can see. It keeps the visit chrome rather than clearing the screen:
/// without it the step, the patient and the way out all disappear at the one
/// moment when a recording is running.
class _Recording extends StatelessWidget {
  const _Recording({
    required this.header,
    required this.state,
    required this.onStop,
  });

  final Widget header;
  final CaptureRecording state;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final minutes = state.elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (state.elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return _CaptureLayout(
      header: header,
      action: _PrimaryCaptureAction(
        icon: Icons.stop,
        label: l10n.captureStop,
        onPressed: onStop,
      ),
      children: [
        const _OpenMicrophone(),
        // The clock and the level float in the middle of what is left, the
        // topics stay above the thumb zone. One [Spacer] would have parked
        // the whole block under the band and left a single hole where the
        // eye goes first.
        const Spacer(),
        Text(
          l10n.captureElapsed(minutes, seconds),
          style: theme.textTheme.displayMedium,
        ),
        SizedBox(height: spacing.s24),
        LevelMeter(level: state.level),
        const Spacer(),
        SizedBox(height: spacing.s24),
        // What there is to say, while it is being said. The screen is not
        // looked at during a recording — but when it is, the answer wanted is
        // "what have I forgotten", and these four are the answer.
        Text(
          l10n.captureTopicsHeading,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: spacing.s8),
        for (final topic in [
          l10n.captureTopicMeasurements,
          l10n.captureTopicWoundBed,
          l10n.captureTopicExudate,
          l10n.captureTopicPain,
        ]) ...[
          SizedBox(height: spacing.s8),
          Text(topic, style: theme.textTheme.bodyLarge),
        ],
      ],
    );
  }
}

/// The one thing on this screen that has to be legible from the doorway.
///
/// A band rather than a dot with a caption: the patient is in the room and
/// entitled to see that a recording is running, and the previous version put
/// the fact on the smallest element of the screen while the clock beside it
/// was twice as loud.
class _OpenMicrophone extends StatelessWidget {
  const _OpenMicrophone();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    return Semantics(
      liveRegion: true,
      label: l10n.captureRecording,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(spacing.r12),
          border: Border.all(color: status.entscheiden, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.fiber_manual_record,
              size: 24,
              color: status.entscheiden,
            ),
            SizedBox(width: spacing.s12),
            // One statement, not two. A second badge reading "Mikrofon
            // offen" said the same thing again and pushed the sentence that
            // matters into two lines on a phone whose font is a notch above
            // the default — which is most of them.
            Expanded(
              child: Text(
                l10n.captureRecording,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: status.entscheiden,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Interpreting extends StatelessWidget {
  const _Interpreting();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: spacing.s16),
          Text(l10n.captureInterpreting),
        ],
      ),
    );
  }
}

/// Shown when no recogniser was reachable.
///
/// Framed as a queue, not as an error: the recording is safe and the visit
/// goes on. The wording is the same one the office sync will use later.
class _Queued extends StatelessWidget {
  const _Queued({required this.header, required this.onUseCards});

  final Widget header;
  final VoidCallback? onUseCards;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    return _CaptureLayout(
      header: header,
      action: FilledButton(
        onPressed: onUseCards,
        child: Text(l10n.captureUseCards),
      ),
      children: [
        Row(
          children: [
            Icon(Icons.cloud_off, color: status.offline),
            SizedBox(width: spacing.s8),
            Expanded(
              child: Text(
                l10n.captureQueued,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.s8),
        Text(
          l10n.captureQueuedHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Shown when the microphone is unavailable.
///
/// Explains what the microphone would be for and offers the card mode as an
/// equal path rather than as a consolation prize.
class _NoMicrophone extends StatelessWidget {
  const _NoMicrophone({required this.header, required this.onUseCards});

  final Widget header;
  final VoidCallback? onUseCards;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return _CaptureLayout(
      header: header,
      action: FilledButton(
        onPressed: onUseCards,
        child: Text(l10n.captureUseCards),
      ),
      children: [
        Text(l10n.captureNoMicrophone, style: theme.textTheme.titleMedium),
        SizedBox(height: spacing.s8),
        Text(
          l10n.captureNoMicrophoneHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
