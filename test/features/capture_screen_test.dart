import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/capture/audio_recorder.dart';
import 'package:wunddoku/domain/model/visit_draft.dart';
import 'package:wunddoku/domain/model/visit_standing.dart';
import 'package:wunddoku/shared/text/field_presentation.dart';
import 'package:wunddoku/data/capture/speech_recognizer.dart';
import 'package:wunddoku/features/besuch/ui/capture_screen.dart';
import 'package:wunddoku/features/besuch/ui/capture_view_model.dart';
import 'package:wunddoku/features/besuch/ui/widgets/level_meter.dart';

import '../support/test_app.dart';

const _exampleName = 'befund_01.m4a';
const _exampleTranscript =
    'Länge drei Komma fünf, Breite zwei. Exsudat gering, serös.';

/// A recogniser that always reports being unreachable.
class _OfflineRecognizer implements SpeechRecognizer {
  @override
  Future<String> transcribe(File audio) async =>
      throw const RecognitionUnavailable('no network');
}

void main() {
  late FakeAudioRecorder recorder;
  late CaptureViewModel viewModel;

  setUp(() {
    recorder = FakeAudioRecorder(exampleFile: File('/tmp/$_exampleName'));
  });

  /// Builds the view model and makes sure it is disposed with the test.
  ///
  /// Disposal is not housekeeping here: it closes the microphone, and a test
  /// that leaked a running recorder would also hang on its pending timer.
  CaptureViewModel model({
    SpeechRecognizer? recognizer,
    bool disposeWithTest = true,
  }) {
    viewModel = CaptureViewModel(
      recorder: recorder,
      recognizer:
          recognizer ??
          const CannedSpeechRecognizer({_exampleName: _exampleTranscript}),
    );
    if (disposeWithTest) addTearDown(viewModel.dispose);
    return viewModel;
  }

  /// Taps the start button and lets the asynchronous permission check settle.
  Future<void> startRecording(WidgetTester tester) async {
    await tester.tap(find.text('Aufnahme starten'));
    await tester.pump();
    await tester.pump();
  }

  /// Stops the recording in real time.
  ///
  /// [WidgetTester.runAsync] is needed because stopping awaits the recorder
  /// and the recogniser; inside the fake async zone those futures would never
  /// complete.
  Future<void> stopRecording(WidgetTester tester, CaptureViewModel vm) async {
    await tester.runAsync(vm.stopRecording);
    await tester.pump();
  }

  group('recording', () {
    testWidgets('the idle state names what can be spoken, with examples', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(child: CaptureScreen(viewModel: model())),
      );

      expect(find.textContaining('Sprich Maße'), findsOneWidget);
      expect(find.textContaining('Länge drei Komma fünf'), findsOneWidget);
      expect(find.text('Aufnahme starten'), findsOneWidget);
    });

    testWidgets('a visit under way says what it already holds', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CaptureScreen(
            viewModel: model(),
            standing: VisitStanding(
              draft: const VisitDraft(
                values: {
                  'measurement.lengthCm': CentimetreValue(3.5),
                  'measurement.widthCm': CentimetreValue(2),
                  'tissue.granulation': PercentValue(60),
                },
              ),
              expectedSlots: FieldPresentation.woundBedSlots,
              photoCount: 1,
              markedPhotoCount: 1,
            ),
          ),
        ),
      );

      // An interruption is normal here, and the record is what the nurse
      // returns to — so the screen has to show it.
      // Three figures, largest first: how far am I, and what still stops me
      // from leaving the flat.
      expect(find.text('3'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('Werte'), findsOneWidget);
      expect(find.text('fehlen'), findsOneWidget);
      // The tick says at least one of them carries an outline.
      expect(find.text('1'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('Fotos'), findsOneWidget);
    });

    testWidgets('a retaken photo does not claim both are marked', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: CaptureScreen(
            viewModel: model(),
            standing: VisitStanding(
              draft: const VisitDraft(),
              expectedSlots: FieldPresentation.woundBedSlots,
              photoCount: 2,
              markedPhotoCount: 1,
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('an unmarked photo is stated without a marking clause', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: CaptureScreen(
            viewModel: model(),
            standing: VisitStanding(
              draft: const VisitDraft(),
              expectedSlots: FieldPresentation.woundBedSlots,
              photoCount: 1,
              markedPhotoCount: 0,
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Fotos'), findsOneWidget);

      // The examples are worth their space on an empty visit and in the way
      // on one that is half done.
      expect(find.textContaining('Länge drei Komma fünf'), findsNothing);
    });

    testWidgets('starting shows an unmissable recording state', (tester) async {
      final vm = model();
      await tester.pumpWidget(TestApp(child: CaptureScreen(viewModel: vm)));

      await startRecording(tester);

      expect(find.text('Aufnahme läuft'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.byType(LevelMeter), findsOneWidget);
      expect(vm.isRecording, isTrue);

      await stopRecording(tester, vm);
    });

    testWidgets('stopping interprets the recording and reports it', (
      tester,
    ) async {
      var interpreted = false;
      final vm = model();
      await tester.pumpWidget(
        TestApp(
          child: CaptureScreen(
            viewModel: vm,
            onInterpreted: () => interpreted = true,
          ),
        ),
      );

      await startRecording(tester);
      await stopRecording(tester, vm);

      expect(interpreted, isTrue);
      expect(vm.state, isA<CaptureDone>());
      final done = vm.state as CaptureDone;
      expect(done.result.transcript, _exampleTranscript);
      expect(done.result.proposals, isNotEmpty);
    });

    testWidgets('leaving the screen closes the microphone', (tester) async {
      // Disposes explicitly below, so the tear-down must not do it again.
      final vm = model(disposeWithTest: false);
      await tester.pumpWidget(TestApp(child: CaptureScreen(viewModel: vm)));
      await startRecording(tester);
      expect(recorder.isOpen, isTrue);

      vm.dispose();
      await tester.pump();

      expect(recorder.isOpen, isFalse);
    });
  });

  group('the ways that are not speech', () {
    testWidgets('a denied microphone explains itself and offers the cards', (
      tester,
    ) async {
      recorder.permissionGranted = false;
      var cardsTapped = false;

      await tester.pumpWidget(
        TestApp(
          child: CaptureScreen(
            viewModel: model(),
            onUseCards: () => cardsTapped = true,
          ),
        ),
      );

      await startRecording(tester);

      expect(find.text('Ohne Mikrofon geht es auch.'), findsOneWidget);
      expect(find.textContaining('über die Karten'), findsWidgets);

      await tester.tap(find.text('Über Karten erfassen'));
      expect(cardsTapped, isTrue);
    });

    testWidgets('without a recogniser the recording queues, it does not fail', (
      tester,
    ) async {
      final vm = model(recognizer: _OfflineRecognizer());
      await tester.pumpWidget(TestApp(child: CaptureScreen(viewModel: vm)));

      await startRecording(tester);
      await stopRecording(tester, vm);

      expect(find.text('1 Aufnahme wartet auf Auswertung.'), findsOneWidget);
      expect(vm.state, isA<CaptureQueued>());
      // The audio survives; nothing is lost because the network was absent.
      expect((vm.state as CaptureQueued).audio.path, endsWith(_exampleName));
    });
  });

  group('accessibility', () {
    testWidgets('meets the four guidelines while idle', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(child: CaptureScreen(viewModel: model())),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('meets the four guidelines with a visit under way', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: CaptureScreen(
            viewModel: model(),
            standing: VisitStanding(
              draft: const VisitDraft(
                values: {'measurement.lengthCm': CentimetreValue(3.5)},
              ),
              expectedSlots: FieldPresentation.woundBedSlots,
              photoCount: 1,
              markedPhotoCount: 1,
            ),
          ),
        ),
      );

      // The standing carries two colour-coded lines. Contrast is checked in
      // the state the nurse spends most of a visit in, not only in the empty
      // one she sees for a minute.
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('the open microphone is announced, not only coloured', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final vm = model();
      await tester.pumpWidget(TestApp(child: CaptureScreen(viewModel: vm)));

      await startRecording(tester);
      expect(find.bySemanticsLabel('Aufnahme läuft'), findsOne);

      await stopRecording(tester, vm);
      handle.dispose();
    });

    testWidgets('survives 200 percent text scaling', (tester) async {
      await tester.pumpWidget(
        TestApp(textScale: 2, child: CaptureScreen(viewModel: model())),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('goldens', () {
    testWidgets('a visit under way', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: CaptureScreen(
            viewModel: model(),
            context: 'Mustermann · linker Unterschenkel, distal',
            onUseCards: () {},
            onTakePhoto: () {},
            onShowHistory: () {},
            onFinishVisit: () {},
            standing: VisitStanding(
              draft: const VisitDraft(
                values: {
                  'measurement.lengthCm': CentimetreValue(3.5),
                  'measurement.widthCm': CentimetreValue(2),
                  'tissue.granulation': PercentValue(60),
                },
              ),
              expectedSlots: FieldPresentation.woundBedSlots,
              photoCount: 1,
              markedPhotoCount: 1,
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(CaptureScreen),
        matchesGoldenFile('goldens/capture_standing.png'),
      );
    });

    testWidgets('a visit under way, dark', (tester) async {
      await tester.pumpWidget(
        TestApp(
          brightness: Brightness.dark,
          child: CaptureScreen(
            viewModel: model(),
            context: 'Mustermann · linker Unterschenkel, distal',
            onUseCards: () {},
            onTakePhoto: () {},
            onShowHistory: () {},
            onFinishVisit: () {},
            standing: VisitStanding(
              draft: const VisitDraft(
                values: {
                  'measurement.lengthCm': CentimetreValue(3.5),
                  'measurement.widthCm': CentimetreValue(2),
                  'tissue.granulation': PercentValue(60),
                },
              ),
              expectedSlots: FieldPresentation.woundBedSlots,
              photoCount: 1,
              markedPhotoCount: 1,
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(CaptureScreen),
        matchesGoldenFile('goldens/capture_standing_dark.png'),
      );
    });

    testWidgets('a visit under way at 200 percent text', (tester) async {
      await tester.pumpWidget(
        TestApp(
          textScale: 2,
          child: CaptureScreen(
            viewModel: model(),
            context: 'Mustermann · linker Unterschenkel, distal',
            onUseCards: () {},
            onTakePhoto: () {},
            onShowHistory: () {},
            onFinishVisit: () {},
            standing: VisitStanding(
              draft: const VisitDraft(
                values: {'measurement.lengthCm': CentimetreValue(3.5)},
              ),
              expectedSlots: FieldPresentation.woundBedSlots,
              photoCount: 2,
              markedPhotoCount: 1,
            ),
          ),
        ),
      );
      await tester.pump();

      // People run their phones at more than 100 percent, and the header was
      // the first thing to break when they do.
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CaptureScreen),
        matchesGoldenFile('goldens/capture_standing_text200.png'),
      );
    });

    testWidgets('idle', (tester) async {
      await tester.pumpWidget(
        TestApp(child: CaptureScreen(viewModel: model())),
      );
      await tester.pump();
      await expectLater(
        find.byType(CaptureScreen),
        matchesGoldenFile('goldens/capture_idle.png'),
      );
    });

    testWidgets('recording', (tester) async {
      final vm = model();
      await tester.pumpWidget(TestApp(child: CaptureScreen(viewModel: vm)));
      await startRecording(tester);

      // A fixed number of ticks keeps the level meter deterministic.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 200));

      await expectLater(
        find.byType(CaptureScreen),
        matchesGoldenFile('goldens/capture_recording.png'),
      );

      await stopRecording(tester, vm);
    });
  });
}
