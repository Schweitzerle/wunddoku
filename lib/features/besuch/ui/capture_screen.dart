import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.onInterpreted,
    this.onUseCards,
    super.key,
  });

  final CaptureViewModel viewModel;

  /// Called when a recording has been turned into field proposals.
  final VoidCallback? onInterpreted;

  /// Called for the equal path without speech.
  final VoidCallback? onUseCards;

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
      appBar: AppBar(title: Text(l10n.captureTitle)),
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
          _ => _Idle(onStart: _toggleRecording),
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
          Expanded(
            child: SingleChildScrollView(
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

class _Idle extends StatelessWidget {
  const _Idle({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return _CaptureLayout(
      action: FilledButton.icon(
        onPressed: onStart,
        icon: const Icon(Icons.mic),
        label: Text(l10n.captureStart),
      ),
      children: [
        Text(l10n.captureIdleHint, style: theme.textTheme.bodyMedium),
        SizedBox(height: spacing.s24),
        _Example(text: l10n.captureExampleOne),
        SizedBox(height: spacing.s8),
        _Example(text: l10n.captureExampleTwo),
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
        style: theme.textTheme.bodyMedium?.copyWith(
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
      action: FilledButton.icon(
        onPressed: onStop,
        icon: const Icon(Icons.stop),
        label: Text(l10n.captureStop),
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
