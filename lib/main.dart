import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/capture/audio_recorder.dart';
import 'data/capture/speech_recognizer.dart';
import 'features/besuch/ui/capture_screen.dart';
import 'features/besuch/ui/capture_view_model.dart';
import 'features/besuch/ui/confirmation_screen.dart';
import 'features/besuch/ui/confirmation_view_model.dart';
import 'features/besuch/ui/field_presentation.dart';
import 'l10n/app_localizations.dart';
import 'shared/theme/app_theme.dart';

void main() => runApp(const WunddokuApp());

/// The example file the development recorder hands back.
///
/// Nothing is read from disk yet — the canned recogniser matches on the file
/// name. Real recordings replace this once the example set is spoken in.
const _exampleAudio = 'befund_01.m4a';

/// A dictation from the example set.
///
/// Synthetic on purpose: no real patient data reaches development, tests or
/// screenshots (`datenschutz-art9.md`). It exercises every row state — two
/// values heard clearly, one implausible, one inflected term, several fields
/// never mentioned.
const _exampleTranscript =
    'Länge drei Komma fünf, Breite zwei, Tiefe fünfzig. '
    'Granulationsgewebe sechzig Prozent. Exsudat gering, serös.';

/// The application shell.
class WunddokuApp extends StatelessWidget {
  const WunddokuApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    debugShowCheckedModeBanner: false,
    home: const VisitCorridor(),
  );
}

/// The two phases of a visit, in the order the nurse works through them.
///
/// Phase A is the recording at the open dressing; phase B is the check once
/// the hands are free. Wiring them here rather than in a router keeps the
/// corridor readable — it is a fixed sequence, not free navigation. See
/// `docs/ux/flows.md`.
class VisitCorridor extends StatefulWidget {
  const VisitCorridor({super.key});

  @override
  State<VisitCorridor> createState() => _VisitCorridorState();
}

class _VisitCorridorState extends State<VisitCorridor> {
  late final CaptureViewModel _capture;

  @override
  void initState() {
    super.initState();
    _capture = CaptureViewModel(
      recorder: FakeAudioRecorder(
        exampleFile: File('${Directory.systemTemp.path}/$_exampleAudio'),
      ),
      recognizer: const CannedSpeechRecognizer({
        _exampleAudio: _exampleTranscript,
      }),
    );
  }

  @override
  void dispose() {
    _capture.dispose();
    super.dispose();
  }

  Future<void> _openConfirmation() async {
    final state = _capture.state;
    if (state is! CaptureDone) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConfirmationScreen(
          viewModel: ConfirmationViewModel(
            expectedSlots: FieldPresentation.woundBedSlots,
            result: state.result,
          ),
          onAccept: () => Navigator.of(context).pop(),
        ),
      ),
    );

    // Coming back means the visit starts over from the recording step.
    if (mounted) _capture.reset();
  }

  @override
  Widget build(BuildContext context) =>
      CaptureScreen(viewModel: _capture, onInterpreted: _openConfirmation);
}
