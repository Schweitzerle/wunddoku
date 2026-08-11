import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/media/wound_camera.dart';
import 'package:wunddoku/features/besuch/ui/photo_screen.dart';

import '../support/fake_camera.dart';
import '../support/test_app.dart';

/// A synthetic stand-in for a wound photo — never a real one.
Future<Uint8List> _syntheticPhoto(Color colour) async {
  final recorder = ui.PictureRecorder();
  const size = Size(120, 90);
  Canvas(recorder, Offset.zero & size)
    ..drawRect(Offset.zero & size, Paint()..color = const Color(0xFFB08068))
    ..drawOval(const Rect.fromLTWH(35, 25, 50, 40), Paint()..color = colour);

  final image = await recorder.endRecording().toImage(120, 90);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  late Uint8List photoBytes;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.runAsync(() async {
      photoBytes = await _syntheticPhoto(const Color(0xFF9C3B2E));
    });
  });

  group('the viewfinder', () {
    testWidgets('shows the previous photo as a framing aid', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: PhotoScreen(
            camera: FakeCamera(photo: photoBytes),
            previousPhoto: MemoryImage(photoBytes),
          ),
        ),
      );
      await tester.pump();

      // Two photos of a wound only compare if the framing roughly matches.
      expect(find.byType(Image), findsOneWidget);
      expect(
        find.text(
          'Gleicher Abstand wie beim letzten Mal — das Geisterbild hilft beim '
          'Ausrichten.',
        ),
        findsOneWidget,
      );
      expect(find.text('Voriges Foto ausblenden'), findsOneWidget);
    });

    testWidgets('the framing aid can be switched off', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: PhotoScreen(
            camera: FakeCamera(photo: photoBytes),
            previousPhoto: MemoryImage(photoBytes),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      expect(find.byType(Image), findsNothing);
      expect(find.text('Voriges Foto einblenden'), findsOneWidget);
    });

    testWidgets('says so when there is nothing to line up against', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: PhotoScreen(camera: FakeCamera(photo: photoBytes)),
        ),
      );
      await tester.pump();

      expect(find.byType(SwitchListTile), findsNothing);
      expect(
        find.text(
          'Erstes Foto dieser Wunde. Formatiere frontal und mit '
          'gleichbleibendem Abstand.',
        ),
        findsOneWidget,
      );
    });
  });

  group('taking a picture', () {
    testWidgets('is checked before it is kept', (tester) async {
      Uint8List? kept;
      final camera = FakeCamera(photo: photoBytes);
      await tester.pumpWidget(
        TestApp(
          child: PhotoScreen(camera: camera, onTaken: (b) => kept = b),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Foto aufnehmen'));
      await tester.pump();

      // The picture is shown before it counts: a blurred wound photo found in
      // the office is a second visit.
      expect(camera.shots, 1);
      expect(kept, isNull);
      expect(find.text('Neu aufnehmen'), findsOneWidget);

      await tester.tap(find.text('Foto übernehmen'));
      expect(kept, photoBytes);
    });

    testWidgets('can be discarded and taken again', (tester) async {
      final camera = FakeCamera(photo: photoBytes);
      await tester.pumpWidget(TestApp(child: PhotoScreen(camera: camera)));
      await tester.pump();

      await tester.tap(find.text('Foto aufnehmen'));
      await tester.pump();
      await tester.tap(find.text('Neu aufnehmen'));
      await tester.pump();

      expect(find.text('Foto aufnehmen'), findsOneWidget);
      expect(find.text('Foto übernehmen'), findsNothing);
    });

    testWidgets('a failing shutter does not end the visit', (tester) async {
      final camera = FakeCamera();
      await tester.pumpWidget(TestApp(child: PhotoScreen(camera: camera)));
      await tester.pump();

      await tester.tap(find.text('Foto aufnehmen'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Kamera lässt sich nicht starten'), findsOneWidget);
      expect(find.text('Ohne Foto weiter'), findsOneWidget);
    });
  });

  group('when the camera stays dark', () {
    testWidgets('a missing permission offers a way on', (tester) async {
      var skipped = false;
      await tester.pumpWidget(
        TestApp(
          child: PhotoScreen(
            camera: FakeCamera(failure: CameraFailure.denied),
            onSkipped: () => skipped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Kein Zugriff auf die Kamera'), findsOneWidget);

      // The finding is what the visit is for; it must never hang on a
      // permission dialog.
      await tester.tap(find.text('Ohne Foto weiter'));
      expect(skipped, isTrue);
    });

    testWidgets('retrying starts the camera once more', (tester) async {
      final camera = FakeCamera(failure: CameraFailure.unavailable);
      await tester.pumpWidget(TestApp(child: PhotoScreen(camera: camera)));
      await tester.pump();

      expect(find.text('Keine Kamera gefunden'), findsOneWidget);
      expect(camera.starts, 1);

      camera.failure = null;
      camera.photo = photoBytes;
      await tester.tap(find.text('Erneut versuchen'));
      await tester.pump();

      expect(camera.starts, 2);
      expect(find.text('Foto aufnehmen'), findsOneWidget);
    });
  });

  testWidgets('leaving the screen releases the camera', (tester) async {
    final camera = FakeCamera(photo: photoBytes);
    await tester.pumpWidget(TestApp(child: PhotoScreen(camera: camera)));
    await tester.pump();

    await tester.pumpWidget(const TestApp(child: SizedBox()));

    // A viewfinder left running behind the next screen drains a phone that
    // has to last a whole tour.
    expect(camera.disposed, isTrue);
  });

  group('accessibility', () {
    testWidgets('meets the four guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: PhotoScreen(
            camera: FakeCamera(photo: photoBytes),
            previousPhoto: MemoryImage(photoBytes),
          ),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('survives 200 percent text scaling', (tester) async {
      await tester.pumpWidget(
        TestApp(
          textScale: 2,
          child: PhotoScreen(
            camera: FakeCamera(photo: photoBytes),
            previousPhoto: MemoryImage(photoBytes),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('goldens', () {
    testWidgets('viewfinder with the framing aid', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: PhotoScreen(
            camera: FakeCamera(photo: photoBytes),
            previousPhoto: MemoryImage(photoBytes),
          ),
        ),
      );
      await tester.runAsync(() async {
        await precacheImage(
          MemoryImage(photoBytes),
          tester.element(find.byType(PhotoScreen)),
        );
      });
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PhotoScreen),
        matchesGoldenFile('goldens/photo_viewfinder.png'),
      );
    });

    testWidgets('camera denied', (tester) async {
      await tester.pumpWidget(
        TestApp(
          brightness: Brightness.dark,
          child: PhotoScreen(camera: FakeCamera(failure: CameraFailure.denied)),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PhotoScreen),
        matchesGoldenFile('goldens/photo_denied_dark.png'),
      );
    });
  });
}
