import 'dart:io';

/// Turns a recorded audio file into a verbatim transcript.
///
/// This is the seam the whole capture pipeline hangs on: behind it can sit a
/// cloud transcription service, an on-device model or — during development
/// without a Mistral key — canned example recordings. The provider never
/// appears above this interface (see `21-flutter-architektur.md` and the
/// Art. 9 requirement to keep on-device processing a drop-in swap).
abstract interface class SpeechRecognizer {
  /// The verbatim transcript of [audio].
  ///
  /// Implementations must not paraphrase or normalise: the transcript is
  /// stored as evidence, and the field mapping needs the original wording.
  /// Throws [RecognitionUnavailable] when the recogniser cannot run at all
  /// (no network, missing service) — the caller queues the recording and
  /// keeps the audio.
  Future<String> transcribe(File audio);
}

/// The recogniser cannot run right now; the recording should be queued.
class RecognitionUnavailable implements Exception {
  const RecognitionUnavailable(this.reason);

  /// Log-safe description. Never contains transcript or audio content.
  final String reason;

  @override
  String toString() => 'RecognitionUnavailable: $reason';
}

/// Development recogniser: serves transcripts for known example recordings.
///
/// Keyed by file name so example audio files and their expected transcripts
/// can live together under `assets/examples/`. Unknown files fail loudly —
/// silently returning an empty transcript would look like a working pipeline
/// with a mute nurse.
class CannedSpeechRecognizer implements SpeechRecognizer {
  const CannedSpeechRecognizer(this._transcriptsByFileName);

  final Map<String, String> _transcriptsByFileName;

  @override
  Future<String> transcribe(File audio) async {
    final name = audio.uri.pathSegments.last;
    final transcript = _transcriptsByFileName[name];
    if (transcript == null) {
      throw StateError('no canned transcript for "$name"');
    }
    return transcript;
  }
}
