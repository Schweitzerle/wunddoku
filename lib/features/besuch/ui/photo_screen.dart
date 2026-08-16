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
    this.onTaken,
    this.onSkipped,
    this.onSelectStep,
    super.key,
  });

  final WoundCamera camera;

  /// The photo of the last visit, used as the framing aid.
  final ImageProvider? previousPhoto;

  /// Called with the encoded bytes once the nurse accepts a picture.
  final ValueChanged<Uint8List>? onTaken;

  /// Called when the visit continues without a photo.
  ///
  /// Always reachable: a camera that will not start must never be the reason
  /// a finding goes undocumented.
  final VoidCallback? onSkipped;

  /// Called with the step of the visit the nurse tapped in the band.
  final void Function(VisitStep step)? onSelectStep;

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  CameraFailure? _failure;
  bool _starting = true;
  bool _ghostVisible = true;
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
            // The band, not a title: the photo is the third step of the
            // visit, and this is where the visit says so.
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
                      l10n.photoTitle,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.s16),
                ],
              ),
            ),
            SizedBox(height: spacing.s8),
            VisitBand(
              current: VisitStep.photo,
              onSelect: widget.onSelectStep,
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
      ghostVisible: _ghostVisible,
      onGhostChanged: (visible) => setState(() => _ghostVisible = visible),
      onShutter: _shutterBusy ? null : _shoot,
    );
  }
}

/// The live viewfinder with the framing aid over it.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder({
    required this.preview,
    required this.previousPhoto,
    required this.ghostVisible,
    required this.onGhostChanged,
    required this.onShutter,
  });

  final Widget preview;
  final ImageProvider? previousPhoto;
  final bool ghostVisible;
  final ValueChanged<bool> onGhostChanged;
  final VoidCallback? onShutter;

  /// How strongly the previous photo shows through.
  ///
  /// Enough to line up an outline, faint enough that it is never mistaken for
  /// what the camera sees right now.
  static const _ghostOpacity = 0.35;

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
            previous == null ? l10n.photoHintFirst : l10n.photoHint,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.s16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(spacing.r12),
              child: ColoredBox(
                color: status.mediaGround,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    preview,
                    if (previous != null && ghostVisible)
                      // Image's own opacity blends while painting. Wrapping
                      // this in Opacity would force a saveLayer over the live
                      // viewfinder every single frame.
                      ExcludeSemantics(
                        child: Image(
                          image: previous,
                          fit: BoxFit.contain,
                          opacity: const AlwaysStoppedAnimation(_ghostOpacity),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (previous != null)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s16,
              vertical: spacing.s8,
            ),
            child: SwitchListTile(
              value: ghostVisible,
              onChanged: onGhostChanged,
              contentPadding: EdgeInsets.zero,
              // The label names the state, never the action: a switch that
              // reads "ausblenden" while it is on says the opposite of what
              // it does, and a screen reader announces exactly that pair.
              title: Text(l10n.photoGhost, style: theme.textTheme.bodyLarge),
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
