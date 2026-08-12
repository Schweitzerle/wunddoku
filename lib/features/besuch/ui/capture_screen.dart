import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/model/visit_standing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import 'capture_view_model.dart';
import 'widgets/level_meter.dart';

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
    this.standing = const VisitStanding.empty(),
    this.onInterpreted,
    this.onUseCards,
    this.onTakePhoto,
    this.onFinishVisit,
    this.onShowHistory,
    super.key,
  });

  final CaptureViewModel viewModel;

  /// Whose wound is being documented, for the second line of the header.
  final String? context;

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
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final spacing = context.spacing;
    final context_ = widget.context;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.captureTitle),
            // Whose wound this is. Without it the corridor is a screen with
            // no address, and "back" leads somewhere unknown.
            if (context_ != null)
              Text(
                context_,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          if (widget.onFinishVisit != null)
            Padding(
              padding: EdgeInsets.only(right: spacing.s12),
              child: FilledButton.tonal(
                onPressed: widget.onFinishVisit,
                style: FilledButton.styleFrom(
                  minimumSize: Size(0, spacing.s48),
                  padding: EdgeInsets.symmetric(horizontal: spacing.s16),
                  textStyle: theme.textTheme.labelLarge,
                ),
                child: Text(l10n.captureFinishShort),
              ),
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => switch (widget.viewModel.state) {
          CaptureUnavailable() => _NoMicrophone(onUseCards: widget.onUseCards),
          CaptureQueued() => _Queued(onUseCards: widget.onUseCards),
          CaptureInterpreting() => const _Interpreting(),
          final CaptureRecording state => _Recording(
            state: state,
            onStop: _toggleRecording,
          ),
          _ => _Idle(
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
  const _CaptureLayout({required this.children, required this.action});

  final List<Widget> children;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Content gathers at the bottom rather than filling from the top:
          // this screen is worked one-handed, and everything the nurse might
          // touch belongs inside the thumb's reach.
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.fromLTRB(
                spacing.s24,
                spacing.s24,
                spacing.s24,
                spacing.s24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.s24,
              0,
              spacing.s24,
              spacing.s24,
            ),
            child: action,
          ),
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
        textStyle: theme.textTheme.titleMedium,
      ),
      icon: Icon(icon, size: 28),
      label: Text(label),
    );
  }
}

class _Idle extends StatelessWidget {
  const _Idle({
    required this.standing,
    required this.onStart,
    required this.onUseCards,
    required this.onTakePhoto,
    required this.onShowHistory,
  });

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
      action: _PrimaryCaptureAction(
        icon: Icons.mic,
        label: l10n.captureStart,
        onPressed: onStart,
      ),
      children: [
        // On a visit under way the standing leads: the first thing a nurse
        // coming back from an interruption needs is where she left off.
        if (!standing.isEmpty) ...[
          _StandingCard(standing: standing),
          SizedBox(height: spacing.s24),
        ],
        Text(l10n.captureIdleHint, style: theme.textTheme.bodyMedium),
        if (standing.isEmpty) ...[
          SizedBox(height: spacing.s16),
          _Example(text: l10n.captureExampleOne),
          SizedBox(height: spacing.s8),
          _Example(text: l10n.captureExampleTwo),
        ],
        SizedBox(height: spacing.s24),
        Text(
          l10n.captureWaysHeading,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: spacing.s8),
        _Way(
          icon: Icons.checklist,
          label: l10n.captureUseCards,
          onTap: onUseCards,
        ),
        _Way(
          icon: Icons.photo_camera_outlined,
          label: l10n.captureTakePhoto,
          onTap: onTakePhoto,
        ),
        _Way(
          icon: Icons.show_chart,
          label: l10n.captureShowHistory,
          onTap: onShowHistory,
        ),
      ],
    );
  }
}

/// An equal path, drawn as something you press.
///
/// Speech is the shortcut, never the only way (`23-a11y.md`) — so these may
/// not look like footnotes under the microphone button. A row with a surface
/// behind it, an icon and a chevron reads as a target; a bare text button
/// next to a 96-point button does not.
class _Way extends StatelessWidget {
  const _Way({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final enabled = onTap != null;
    final foreground = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.s8),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(spacing.r12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(spacing.r12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s16,
              vertical: spacing.s16,
            ),
            child: Row(
              children: [
                Icon(icon, color: foreground),
                SizedBox(width: spacing.s16),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: foreground,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
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
            _Metric(
              value: '${standing.photoCount}',
              label: standing.markedPhotoCount > 0
                  ? '${l10n.captureMetricPhotos}, ${l10n.captureMarkedShort}'
                  : l10n.captureMetricPhotos,
            ),
            _Metric(
              value: complete ? '✓' : '${standing.gapCount}',
              label: complete
                  ? l10n.captureMetricComplete
                  : l10n.captureMetricGaps,
              // The only figure that decides whether the visit can be left
              // as it is — so it is the only one that carries colour.
              colour: complete ? status.sicher : status.pruefen,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, this.colour});

  final String value;
  final String label;
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colour ?? theme.colorScheme.onSurface,
            ),
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

    return Container(
      padding: EdgeInsets.all(spacing.s12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(spacing.r12),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Recording extends StatelessWidget {
  const _Recording({required this.state, required this.onStop});

  final CaptureRecording state;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    final minutes = state.elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (state.elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return _CaptureLayout(
      action: _PrimaryCaptureAction(
        icon: Icons.stop,
        label: l10n.captureStop,
        onPressed: onStop,
      ),
      children: [
        Semantics(
          liveRegion: true,
          label: l10n.captureRecording,
          excludeSemantics: true,
          child: Row(
            children: [
              Icon(Icons.fiber_manual_record, color: status.entscheiden),
              SizedBox(width: spacing.s8),
              Text(
                l10n.captureRecording,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: status.entscheiden,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.s24),
        Text(
          l10n.captureElapsed(minutes, seconds),
          style: theme.textTheme.displayMedium,
        ),
        SizedBox(height: spacing.s24),
        LevelMeter(level: state.level),
      ],
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
  const _Queued({required this.onUseCards});

  final VoidCallback? onUseCards;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    return _CaptureLayout(
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
  const _NoMicrophone({required this.onUseCards});

  final VoidCallback? onUseCards;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return _CaptureLayout(
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
