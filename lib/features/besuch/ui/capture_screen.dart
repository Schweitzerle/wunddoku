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
    this.standing = const VisitStanding.empty(),
    this.onInterpreted,
    this.onUseCards,
    this.onTakePhoto,
    this.onFinishVisit,
    this.onShowHistory,
    super.key,
  });

  final CaptureViewModel viewModel;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.captureTitle),
        actions: [
          if (widget.onFinishVisit != null)
            TextButton(
              onPressed: widget.onFinishVisit,
              child: Text(l10n.captureFinishVisit),
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
        // coming back from an interruption needs is where she left off, not
        // a reminder of what can be said.
        if (standing.isEmpty) ...[
          Text(l10n.captureIdleHint, style: theme.textTheme.bodyMedium),
          SizedBox(height: spacing.s24),
          _Example(text: l10n.captureExampleOne),
          SizedBox(height: spacing.s8),
          _Example(text: l10n.captureExampleTwo),
        ] else ...[
          _Standing(standing: standing),
          SizedBox(height: spacing.s12),
          Text(l10n.captureIdleHint, style: theme.textTheme.bodyMedium),
        ],
        SizedBox(height: spacing.s16),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onUseCards,
            icon: const Icon(Icons.checklist),
            label: Text(l10n.captureUseCards),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onTakePhoto,
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(l10n.captureTakePhoto),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onShowHistory,
            icon: const Icon(Icons.timeline),
            label: Text(l10n.captureShowHistory),
          ),
        ),
      ],
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

/// What the visit already holds, in one line per fact.
///
/// Deliberately plain text rather than a card: it is the state of the record,
/// not another thing to operate, and the screen's one large target must stay
/// the only thing that draws the thumb.
class _Standing extends StatelessWidget {
  const _Standing({required this.standing});

  final VisitStanding standing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (standing.valueCount > 0)
            Text(
              l10n.captureStandingValues(standing.valueCount),
              style: theme.textTheme.titleMedium,
            ),
          if (standing.photoCount > 0)
            Text(
              l10n.captureStandingPhoto(
                standing.photoCount,
                standing.markedPhotoCount,
              ),
              style: theme.textTheme.bodyMedium,
            ),
          SizedBox(height: spacing.s4),
          Text(
            l10n.captureStandingGaps(standing.gapCount),
            style: theme.textTheme.bodyMedium?.copyWith(
              // A gap is allowed and stays colourless; only the absence of
              // gaps is worth a word of its own.
              color: standing.gapCount == 0 ? status.sicher : status.luecke,
            ),
          ),
        ],
      ),
    );
  }
}
