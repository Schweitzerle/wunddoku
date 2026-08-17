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
    this.onFinishVisit,
    this.onShowHistory,
    this.onSelectStep,
    this.onOpenArea,
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


  /// Called with the step of the visit the nurse tapped in the band.
  final void Function(VisitStep step)? onSelectStep;

  /// Called with the area of the finding the nurse wants to fill in.
  final void Function(StandingArea area)? onOpenArea;

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
      onShowHistory: widget.onShowHistory,
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
            onFinishVisit: widget.onFinishVisit,
            onOpenArea: widget.onOpenArea,
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
    this.lead,
  });

  final List<Widget> children;
  final Widget action;

  /// The visit header and band, where this state carries them.
  final Widget? header;

  /// What the visit needs next, above the one large target. Null when there
  /// is no obvious answer.
  final Widget? lead;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?header,
          // Reading fills from the top, and what is touched sits low where
          // the thumb is.
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
                    // shorter, so a [Spacer] among the children turns what
                    // used to be dead space at the bottom into the gap
                    // between two groups. Costs one intrinsic pass over a
                    // handful of leaves; this is a screen, not a list
                    // (`25-performance.md`).
                    constraints: BoxConstraints(
                      minHeight: viewport.maxHeight - padding.vertical,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _Dock(lead: lead, action: action),
        ],
      ),
    );
  }
}

/// What the visit needs next, when the finding has nothing open.
///
/// Quieter than the microphone above it and louder than a line of text: the
/// nurse decides whether she is done, the app only stops hiding the door.
class _FinishSuggestion extends StatelessWidget {
  const _FinishSuggestion({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.check_circle_outline),
      label: Text(l10n.captureFinishVisit),
      style: OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(spacing.comfortTouch),
      ),
    );
  }
}

/// The area the thumb owns: the equal paths, then the one large action.
class _Dock extends StatelessWidget {
  const _Dock({required this.lead, required this.action});

  final Widget? lead;
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
          if (lead != null) ...[lead!, SizedBox(height: spacing.s12)],
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
    required this.onFinishVisit,
    required this.onOpenArea,
  });

  final Widget header;

  /// Whose wound is open in front of the nurse.
  final String? address;

  final VisitStanding standing;

  final VoidCallback onStart;

  /// Closes the visit, offered here when there is nothing left open.
  final VoidCallback? onFinishVisit;

  /// Opens the place where an area of the finding is filled in.
  final void Function(StandingArea area)? onOpenArea;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return _CaptureLayout(
      header: header,
      action: _PrimaryCaptureAction(
        icon: Icons.mic,
        // Nothing starts on a visit that already carries something, and a
        // screen that says "Aufnahme starten" over eight recorded values
        // reads as though the eight were gone.
        label: standing.isEmpty ? l10n.captureStart : l10n.captureContinue,
        onPressed: onStart,
      ),
      // What the visit needs next, when there is an obvious answer. A
      // finding with nothing open wants closing, and leaving that to a thin
      // outline in the header while the loudest thing on screen says "keep
      // talking" points the nurse at the one action she does not need.
      lead: standing.isEmpty || onFinishVisit == null
          ? null
          : standing.areas.every((area) => area.isComplete)
          ? _FinishSuggestion(onPressed: onFinishVisit!)
          : null,
      children: [
        // Whose wound this is, in the body rather than in the app bar: at the
        // text sizes people actually run their phones at, a second line up
        // there collides with the title and the action.
        Text(
          standing.isEmpty ? l10n.captureTitle : l10n.captureTitleResumed,
          style: theme.textTheme.headlineMedium,
        ),
        if (address != null) ...[
          SizedBox(height: spacing.s4),
          _Address(text: address!),
        ],
        SizedBox(height: spacing.s24),
        // On a visit under way the standing leads: the first thing a nurse
        // coming back from an interruption needs is where she left off.
        if (standing.isEmpty)
          // What can be spoken, for a visit that holds nothing yet. Once it
          // holds something the list below says the same in a form that also
          // answers "what is still open", and two of those would compete.
          _Hint(text: l10n.captureIdleHint)
        else
          _AreaList(
            areas: standing.areas,
            openCount: standing.areas.where((a) => !a.isComplete).length,
            onOpen: onOpenArea,
          ),
        // Whatever room is left over lands here rather than at the bottom of
        // the screen: what follows then stands a constant 24 dp above the
        // thumb zone. When the content is taller than the viewport this
        // collapses to nothing and the screen simply scrolls.
        const Spacer(),
        // The examples teach what a spoken finding sounds like. Once the
        // visit holds something, the list above answers the question the
        // nurse actually has — what is still open — and the examples give
        // way to it.
        if (standing.isEmpty) ...[
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
      ],
    );
  }
}

/// The finding by area, with what is in it and what is not.
///
/// Numbers alone ("8 Werte · 2 fehlen") say how much is done but never what.
/// The areas are the ones the nurse speaks in, and each row is the way into
/// the place where that area is filled in — seeing a gap and reaching it are
/// one movement, not two (NN/g, *Visibility of System Status*).
class _AreaList extends StatelessWidget {
  const _AreaList({
    required this.areas,
    required this.openCount,
    required this.onOpen,
  });

  final List<StandingArea> areas;

  /// How many areas still want something.
  final int openCount;

  final void Function(StandingArea area)? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.standingHeading,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // The one number that decides whether the visit can be left as
            // it is, next to the list that says which ones they are.
            Text(
              openCount == 0
                  ? l10n.standingAllDone
                  : l10n.standingOpenCount(openCount),
              style: theme.textTheme.labelMedium?.copyWith(
                color: openCount == 0
                    ? context.statusColors.sicher
                    : context.statusColors.pruefen,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.s8),
        for (final area in areas)
          _AreaRow(
            area: area,
            onOpen: onOpen == null ? null : () => onOpen!(area),
          ),
      ],
    );
  }
}

/// One area of the finding: its name, how far it is, and the way there.
class _AreaRow extends StatelessWidget {
  const _AreaRow({required this.area, required this.onOpen});

  final StandingArea area;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    final label = switch (area.id) {
      StandingAreaId.measurements => l10n.standingAreaMeasurements,
      StandingAreaId.woundBed => l10n.standingAreaWoundBed,
      StandingAreaId.exudate => l10n.standingAreaExudate,
      StandingAreaId.pain => l10n.standingAreaPain,
      StandingAreaId.photo => l10n.standingAreaPhoto,
    };
    final state = switch (area) {
      StandingArea(isComplete: true) => l10n.standingComplete,
      StandingArea(isUntouched: true) => l10n.standingOpen,
      _ => l10n.standingPartial(area.done, area.total),
    };

    return Semantics(
      label: '$label, $state',
      button: onOpen != null,
      excludeSemantics: true,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(spacing.r8),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: spacing.minTouch),
          child: Row(
            children: [
              // The mark differs as well as the colour: a tick for done, an
              // empty ring for untouched, a half-filled one in between —
              // colour alone is not a statement in sunlight.
              Icon(
                area.isComplete
                    ? Icons.check_circle
                    : area.isUntouched
                    ? Icons.circle_outlined
                    : Icons.incomplete_circle,
                size: 20,
                color: area.isComplete ? status.sicher : status.luecke,
              ),
              SizedBox(width: spacing.s12),
              Expanded(
                child: Text(label, style: theme.textTheme.bodyLarge),
              ),
              Text(
                state,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: area.isComplete
                      ? theme.colorScheme.onSurfaceVariant
                      : status.luecke,
                ),
              ),
              if (onOpen != null) ...[
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
