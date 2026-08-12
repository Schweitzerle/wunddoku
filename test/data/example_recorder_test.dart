import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/capture/audio_recorder.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('wunddoku_examples');
  });

  tearDown(() async {
    if (directory.existsSync()) await directory.delete(recursive: true);
  });

  ExampleAudioRecorder recorder() => ExampleAudioRecorder(
    assetNames: const ['befund_01.m4a', 'befund_02.m4a'],
    directory: () async => directory,
    // The asset bundle is not available in a plain test run, so the example
    // recordings are read from the repository instead.
    load: (key) async {
      final bytes = await File(key).readAsBytes();
      return ByteData.view(Uint8List.fromList(bytes).buffer);
    },
  );

  /// One full recording, with the level stream listened to throughout.
  ///
  /// Closing a stream nobody listens to never completes; in the app the level
  /// meter is always listening.
  Future<File> record(ExampleAudioRecorder subject) async {
    final levels = subject.start().listen((_) {});
    final file = await subject.stop();
    await levels.cancel();
    return file;
  }

  testWidgets('a recording ends up as a file that actually exists', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final file = await record(recorder());

      // The whole point of this recorder: everything downstream works on
      // files, and a path to nothing hides whatever breaks there.
      expect(file.existsSync(), isTrue);
      expect(await file.length(), greaterThan(1000));
    });
  });

  testWidgets('each recording serves the next example', (tester) async {
    await tester.runAsync(() async {
      final subject = recorder();

      final first = await record(subject);
      final second = await record(subject);
      final third = await record(subject);

      // One run through the app exercises every example rather than the same
      // dictation four times.
      expect(first.path, isNot(second.path));
      expect(third.path, first.path, reason: 'the list starts over');
    });
  });

  testWidgets('stopping closes the microphone', (tester) async {
    await tester.runAsync(() async {
      final subject = recorder();
      final levels = subject.start().listen((_) {});
      expect(subject.isOpen, isTrue);

      await subject.stop();
      await levels.cancel();
      expect(subject.isOpen, isFalse);
    });
  });
}
