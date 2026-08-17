import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../data/media/wound_camera.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import 'widgets/visit_chrome.dart';

/// Takes the wound photo.
///
/// The load-bearing idea here is the **ghost image**: the previous visit's
/// photo lies half transparent over the viewfinder, so the nurse frames the
/// wound the same way as last time. Two photos of a wound are only comparable
/// if distance and angle roughly match — without that aid, a wound looks
/// larger or smaller from one week to the next for no clinical reason.
class PhotoScreen extends StatefulWidget {
  const PhotoScreen({
    required this.camera,
    this.previousPhoto,
    this.previousPhotoUnreadable = false,
    this.onTaken,
    this.onSkipped,
    this.onSelectStep,
    this.visitDate,
    this.onFinishVisit,
    this.onShowHistory,
    super.key,
  });

  final WoundCamera camera;

  /// The photo of the last visit, used as the framing aid.
  final ImageProvider? previousPhoto;

  /// Whether the record holds a previous photo whose file would not read.
  ///
  /// Then the framing aid is missing for a reason, and the screen says so.
  /// Dropping it silently is how a nurse ends up wondering whether she
  /// remembered the aid wrong.
  final bool previousPhotoUnreadable;

  /// Called with the encoded bytes once the nurse accepts a picture.
  final ValueChanged<Uint8List>? onTaken;

  /// Called when the visit continues without a photo.
  ///
  /// Always reachable: a camera that will not start must never be the reason
  /// a finding goes undocumented.
  final VoidCallback? onSkipped;

  /// Called with the step of the visit the nurse tapped in the band.
  final void Function(VisitStep step)? onSelectStep;

  /// When the open visit was started, for the visit header.
  final DateTime? visitDate;

  /// Closes the visit. Carried on every step, never only on the first.
  final VoidCallback? onFinishVisit;

  /// Opens the course of this wound.
  final VoidCallback? onShowHistory;

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  CameraFailure? _failure;
  bool _starting = true;
  double _ghostOpacity = _Viewfinder._ghostDefault;
  bool _shutterBusy = false;
  Uint8List? _taken;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    // Leaving the screen has to release the camera, otherwise the viewfinder
    // keeps running behind the next screen and drains the battery of a phone
    // that has to last a whole tour.
    widget.camera.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _failure = null;
    });
    final failure = await widget.camera.start();
    if (!mounted) return;
    setState(() {
      _failure = failure;
      _starting = false;
    });
  }

  Future<void> _shoot() async {
    if (_shutterBusy) return;
    setState(() => _shutterBusy = true);
    try {
      final bytes = await widget.camera.takePhoto();
      if (!mounted) return;
      setState(() => _taken = bytes);
    } on Exception {
      if (!mounted) return;
      setState(() => _failure = CameraFailure.failed);
    } finally {
      if (mounted) setState(() => _shutterBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The same header as every other step, rather than this screen's
            // own title row: the way out of the visit may not move from step
            // to step (`23-a11y.md`, 3.2.6), and the band already says the
            // word "Foto" one line further down.
            VisitHeader(
              step: VisitStep.photo,
              visitDate: widget.visitDate,
              onBack: Navigator.of(context).canPop()
                  ? () => Navigator.of(context).maybePop()
                  : null,
              onFinish: widget.onFinishVisit,
              onShowHistory: widget.onShowHistory,
              onSelectStep: widget.onSelectStep,
            ),
            SizedBox(height: spacing.s12),
            Expanded(child: _body(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n) {
    final taken = _taken;
    if (taken != null) {
      return _Review(
        photo: taken,
        onAccept: () => widget.onTaken?.call(taken),
        onRetake: () => setState(() => _taken = null),
      );
    }

    final failure = _failure;
    if (failure != null) {
      return _Failed(
        failure: failure,
        onRetry: _start,
        onSkip: widget.onSkipped,
      );
    }

    if (_starting || !widget.camera.isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return _Viewfinder(
      preview: widget.camera.preview(),
      previousPhoto: widget.previousPhoto,
      previousPhotoUnreadable: widget.previousPhotoUnreadable,
      ghostOpacity: _ghostOpacity,
      onGhostOpacityChanged: (value) =>
          setState(() => _ghostOpacity = value),
      onShutter: _shutterBusy ? null : _shoot,
    );
  }
}

/// How strongly the previous photo shows through the viewfinder.
///
/// A slider rather than a switch: how much of the old picture helps depends
/// on the wound and the light, and "on or off" makes that choice for the
/// nurse. Tapping the track sets the value, so the control does not depend
/// on a drag (WCAG 2.5.7).
class _GhostControl extends StatelessWidget {
  const _GhostControl({required this.opacity, required this.onChanged});

  final double opacity;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.photoGhost,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              Text(
                opacity == 0
                    ? l10n.photoGhostOff
                    : l10n.photoGhostStrength((opacity * 100).round()),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(
            // The slider brings its own 48 dp of touch area; without a fixed
            // height it also brings Material's default vertical padding on
            // top of it.
            height: spacing.minTouch,
            child: Slider(
              value: opacity,
              // Steps rather than a continuum: with gloves on, a value that
              // can be hit again next time is worth more than one that can
              // be hit exactly.
              divisions: 10,
              label: l10n.photoGhostStrength((opacity * 100).round()),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// The live viewfinder with the framing aid over it.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder({
    required this.preview,
    required this.previousPhoto,
    required this.previousPhotoUnreadable,
    required this.ghostOpacity,
    required this.onGhostOpacityChanged,
    required this.onShutter,
  });

  final Widget preview;
  final ImageProvider? previousPhoto;
  final bool previousPhotoUnreadable;
  /// How strongly the previous photo shows through; 0 turns it off.
  final double ghostOpacity;

  final ValueChanged<double> onGhostOpacityChanged;
  final VoidCallback? onShutter;

  /// How strongly the previous photo shows through.
  ///
  /// Where the framing aid starts: enough to line up an outline, faint
  /// enough that it is never mistaken for what the camera sees right now.
  /// The nurse moves it from there — a dark wound on a dark leg needs a
  /// different mix than a pale one in daylight.
  static const _ghostDefault = 0.35;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;
    final previous = previousPhoto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.s16,
            0,
            spacing.s16,
            spacing.s12,
          ),
          child: Text(
            previous != null
                ? l10n.photoHint
                : previousPhotoUnreadable
                ? l10n.photoGhostUnreadable
                : l10n.photoHintFirst,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // Edge to edge, without a card around it. The wound is the content
        // of this screen, and 16 dp of surface on either side of it is 16 dp
        // taken from the thing the nurse is aiming.
        Expanded(
          child: ColoredBox(
            color: status.mediaGround,
            child: Stack(
              fit: StackFit.expand,
              children: [
                preview,
                if (previous != null && ghostOpacity > 0)
                  // Image's own opacity blends while painting. Wrapping this
                  // in Opacity would force a saveLayer over the live
                  // viewfinder every single frame.
                  ExcludeSemantics(
                    child: Image(
                      image: previous,
                      fit: BoxFit.contain,
                      opacity: AlwaysStoppedAnimation(ghostOpacity),
                      // A framing aid that cannot be decoded costs the aid
                      // and nothing else — but it may not take the
                      // viewfinder with it.
                      errorBuilder: (context, error, stack) =>
                          const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (previous != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.s16,
              spacing.s8,
              spacing.s16,
              0,
            ),
            child: _GhostControl(
              opacity: ghostOpacity,
              onChanged: onGhostOpacityChanged,
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.s16,
            spacing.s8,
            spacing.s16,
            spacing.s16,
          ),
          child: _Shutter(onPressed: onShutter),
        ),
      ],
    );
  }
}

/// The shutter.
///
/// The largest target on the screen, and at the bottom edge: it is pressed
/// with a gloved thumb while the other hand holds the dressing.
class _Shutter extends StatelessWidget {
  const _Shutter({required this.onPressed});

  final VoidCallback? onPressed;

  /// Height of the shutter, matching the primary capture action.
  static const _height = 96.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SizedBox(
      height: _height,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          // The size has to travel through the button's own style, otherwise
          // a text style from the theme brings onSurface with it and the
          // label loses its contrast against the filled background.
          textStyle: theme.textTheme.titleLarge,
        ),
        icon: const Icon(Icons.photo_camera_outlined, size: 32),
        label: Text(l10n.photoShutter),
      ),
    );
  }
}

/// The picture that was just taken, before it is kept.
class _Review extends StatelessWidget {
  const _Review({
    required this.photo,
    required this.onAccept,
    required this.onRetake,
  });

  final Uint8List photo;
  final VoidCallback onAccept;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;
    final status = context.statusColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.s16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(spacing.r12),
              child: ColoredBox(
                color: status.mediaGround,
                child: Image.memory(photo, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(spacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(onPressed: onAccept, child: Text(l10n.photoAccept)),
              SizedBox(height: spacing.s8),
              OutlinedButton(
                onPressed: onRetake,
                child: Text(l10n.photoRetake),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// What is shown instead of the viewfinder when the camera stays dark.
class _Failed extends StatelessWidget {
  const _Failed({
    required this.failure,
    required this.onRetry,
    required this.onSkip,
  });

  final CameraFailure failure;
  final VoidCallback onRetry;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final title = switch (failure) {
      CameraFailure.denied => l10n.photoDeniedTitle,
      CameraFailure.unavailable => l10n.photoUnavailableTitle,
      CameraFailure.failed => l10n.photoFailedTitle,
    };

    return Padding(
      padding: EdgeInsets.all(spacing.s16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          SizedBox(height: spacing.s8),
          Text(
            l10n.photoDeniedBody,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.s24),
          // Continuing without a photo comes first: the finding is what the
          // visit is for, and it must never hang on the camera.
          FilledButton(onPressed: onSkip, child: Text(l10n.photoSkip)),
          SizedBox(height: spacing.s8),
          OutlinedButton(onPressed: onRetry, child: Text(l10n.photoRetry)),
        ],
      ),
    );
  }
}
