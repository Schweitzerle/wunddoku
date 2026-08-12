import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart' show ByteData, rootBundle;

/// Records the spoken finding to a file.
///
/// The port exists for the same reason as [SpeechRecognizer]: the recording
/// side has to be developable and demonstrable without a provider, and the
/// audio itself is health data, so where it lands is an architectural
/// decision rather than a detail of a plugin.
abstract interface class AudioRecorder {
  /// Whether the microphone may be used.
  ///
  /// Asked before starting so the screen can explain what the microphone is
  /// for instead of showing a bare system prompt.
  Future<bool> hasPermission();

  /// Requests microphone access, returning whether it was granted.
  Future<bool> requestPermission();

  /// Starts recording into a new file and emits the input level.
  ///
  /// The stream carries values between 0 and 1 and is what the level meter
  /// draws. It stops when [stop] is called.
  Stream<double> start();

  /// Stops the recording and returns the file it was written to.
  ///
  /// The file exists before anything is sent anywhere — a recording that is
  /// lost because the network failed would be a lost visit.
  Future<File> stop();
}

/// A recorder for development and tests.
///
/// Produces a deterministic level curve and hands back a file that is expected
/// to hold one of the example dictations, so the whole capture flow can be
/// exercised without a microphone.
class FakeAudioRecorder implements AudioRecorder {
  FakeAudioRecorder({
    required this.exampleFile,
    this.permissionGranted = true,
    this.tick = const Duration(milliseconds: 100),
  });

  /// The file [stop] returns; pairs with a canned transcript.
  final File exampleFile;

  /// What [hasPermission] reports, so the denied state can be exercised.
  bool permissionGranted;

  final Duration tick;

  StreamController<double>? _levels;
  Timer? _timer;

  /// Whether the microphone is currently open.
  ///
  /// Exists so a test can assert that leaving the screen actually closed it.
  bool get isOpen => _timer != null;

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Stream<double> start() {
    // Closed in stop(); the analyzer cannot see across the two methods.
    // ignore: close_sinks
    final controller = StreamController<double>();
    _levels = controller;

    var step = 0;
    _timer = Timer.periodic(tick, (_) {
      // A slow wave with a little jitter — enough for the meter to look alive
      // without being random, which would make goldens flaky.
      final wave = (sin(step / 4) + 1) / 2;
      controller.add(0.2 + 0.6 * wave);
      step++;
    });

    return controller.stream;
  }

  @override
  Future<File> stop() async {
    _timer?.cancel();
    _timer = null;
    await _levels?.close();
    _levels = null;
    return exampleFile;
  }
}

/// Serves the bundled example dictations as real files.
///
/// The development path needs an actual recording on disk, not just a name:
/// everything downstream — the recogniser port, the queue when transcription
/// is unavailable, the deletion path for raw audio — works on files, and a
/// seam that hands back a path to nothing hides whatever breaks there.
///
/// Each recording serves the next example in turn, so one run through the app
/// exercises all of them: a clean dictation, one with a correction, one with
/// an implausible number, and a fragment.
class ExampleAudioRecorder implements AudioRecorder {
  ExampleAudioRecorder({
    required this.assetNames,
    required Future<Directory> Function() directory,
    Future<ByteData> Function(String key)? load,
    FakeAudioRecorder? levels,
  }) : _directory = directory,
       _load = load ?? rootBundle.load,
       _levels = levels ?? FakeAudioRecorder(exampleFile: File('unused'));

  /// Asset names under `assets/examples/`, in the order they are served.
  final List<String> assetNames;

  final Future<Directory> Function() _directory;

  /// Reads an asset. A seam because the asset bundle is not available in a
  /// plain `flutter test` run.
  final Future<ByteData> Function(String key) _load;

  /// Supplies the level curve; the example recorder only replaces the file.
  final FakeAudioRecorder _levels;

  int _next = 0;

  /// Whether the microphone is currently open.
  bool get isOpen => _levels.isOpen;

  @override
  Future<bool> hasPermission() => _levels.hasPermission();

  @override
  Future<bool> requestPermission() => _levels.requestPermission();

  @override
  Stream<double> start() => _levels.start();

  @override
  Future<File> stop() async {
    await _levels.stop();

    final name = assetNames[_next % assetNames.length];
    _next++;

    final bytes = await _load('assets/examples/$name');
    final file = File('${(await _directory()).path}/$name');
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    return file;
  }
}
