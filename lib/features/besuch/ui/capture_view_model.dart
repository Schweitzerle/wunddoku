import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../data/capture/audio_recorder.dart';
import '../../../data/capture/speech_recognizer.dart';
import '../../../domain/capture/field_proposal.dart';
import '../../../domain/capture/transcript_interpreter.dart';

/// Where the capture step currently stands.
sealed class CaptureState {
  const CaptureState();
}

/// Nothing recorded yet.
final class CaptureIdle extends CaptureState {
  const CaptureIdle();
}

/// The microphone is open.
final class CaptureRecording extends CaptureState {
  const CaptureRecording({required this.level, required this.elapsed});

  /// Input level between 0 and 1, drawn by the meter.
  final double level;

  final Duration elapsed;
}

/// The recording is being turned into fields.
final class CaptureInterpreting extends CaptureState {
  const CaptureInterpreting();
}

/// Interpretation succeeded.
final class CaptureDone extends CaptureState {
  const CaptureDone(this.result);

  final CaptureResult result;
}

/// No recogniser was reachable; the recording waits in the queue.
///
/// Deliberately not an error state: without a network the nurse has done
/// nothing wrong, and the visit continues. The audio is kept.
final class CaptureQueued extends CaptureState {
  const CaptureQueued(this.audio, this.reason);

  final File audio;

  /// Log-safe reason, shown in plain words.
  final String reason;
}

/// The microphone is unavailable; the card mode is the way on.
final class CaptureUnavailable extends CaptureState {
  const CaptureUnavailable(this.reason);

  final String reason;
}

/// Drives the recording step of the visit.
///
/// The screen it belongs to is the one the nurse does *not* look at: both
/// hands are at the dressing and the eyes are on the wound. The view model
/// therefore exposes state that can be rendered as sound and vibration just as
/// well as visually.
class CaptureViewModel extends ChangeNotifier {
  CaptureViewModel({
    required AudioRecorder recorder,
    required SpeechRecognizer recognizer,
    TranscriptInterpreter interpreter = const TranscriptInterpreter(),
  }) : _recorder = recorder,
       _recognizer = recognizer,
       _interpreter = interpreter;

  final AudioRecorder _recorder;
  final SpeechRecognizer _recognizer;
  final TranscriptInterpreter _interpreter;

  StreamSubscription<double>? _levels;
  Stopwatch? _stopwatch;
  Timer? _ticker;

  CaptureState _state = const CaptureIdle();

  /// The current step of the capture.
  CaptureState get state => _state;

  /// Whether the microphone is open right now.
  ///
  /// Drives the visual, audible and haptic indicator together — an open
  /// microphone in someone else's flat must not be possible to overlook.
  bool get isRecording => _state is CaptureRecording;

  /// Starts recording, asking for microphone access if needed.
  ///
  /// Refusal is not a dead end: the state becomes [CaptureUnavailable] and the
  /// screen offers the card mode as an equal path.
  Future<void> startRecording() async {
    if (_state is CaptureRecording) return;

    if (!await _recorder.hasPermission() &&
        !await _recorder.requestPermission()) {
      _set(const CaptureUnavailable('microphone permission denied'));
      return;
    }

    _stopwatch = Stopwatch()..start();
    _set(const CaptureRecording(level: 0, elapsed: Duration.zero));

    _levels = _recorder.start().listen((level) {
      if (_state is! CaptureRecording) return;
      _set(
        CaptureRecording(
          level: level,
          elapsed: _stopwatch?.elapsed ?? Duration.zero,
        ),
      );
    });

    // The elapsed time keeps moving even while the room is quiet and no level
    // events arrive.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state case final CaptureRecording current) {
        _set(
          CaptureRecording(
            level: current.level,
            elapsed: _stopwatch?.elapsed ?? Duration.zero,
          ),
        );
      }
    });
  }

  /// Stops the recording and interprets it.
  Future<void> stopRecording() async {
    if (_state is! CaptureRecording) return;

    await _levels?.cancel();
    _levels = null;
    _ticker?.cancel();
    _ticker = null;
    _stopwatch?.stop();

    final audio = await _recorder.stop();
    _set(const CaptureInterpreting());

    try {
      final transcript = await _recognizer.transcribe(audio);
      _set(CaptureDone(_interpreter.interpret(transcript)));
    } on RecognitionUnavailable catch (error) {
      _set(CaptureQueued(audio, error.reason));
    }
  }

  /// Discards the current outcome and returns to the starting state.
  void reset() {
    _set(const CaptureIdle());
  }

  void _set(CaptureState next) {
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _levels?.cancel();
    _levels = null;
    _ticker?.cancel();
    _ticker = null;

    // Leaving the screen must close the microphone. A recording that outlives
    // its screen would keep listening in someone else's flat with nothing on
    // screen to show it — the one failure this feature must not have.
    if (_stopwatch?.isRunning ?? false) {
      _stopwatch!.stop();
      unawaited(_recorder.stop());
    }

    super.dispose();
  }
}
