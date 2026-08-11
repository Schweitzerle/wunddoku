import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Why the viewfinder cannot be shown.
enum CameraFailure {
  /// The user declined the camera permission, or it was never granted.
  denied,

  /// The device reports no usable camera.
  unavailable,

  /// The camera is there but refused to start.
  failed,
}

/// The viewfinder and the shutter, as this app needs them.
///
/// A port rather than direct use of `camera`: the wound photo screen is the
/// one screen that cannot run in a widget test against real hardware, and it
/// carries the framing aid that the whole visit comparison depends on. Behind
/// this interface the screen is testable, and a plugin swap stays a swap.
abstract interface class WoundCamera {
  /// Whether [preview] can be shown.
  bool get isReady;

  /// Starts the back camera.
  ///
  /// Returns `null` on success, otherwise the reason to show instead of the
  /// viewfinder. Failure is a return value, not an exception: every one of
  /// these cases has a screen state.
  Future<CameraFailure?> start();

  /// The live viewfinder. Only valid while [isReady].
  Widget preview();

  /// Takes a picture and returns its encoded bytes.
  ///
  /// The bytes are never written to a public directory by this call; where the
  /// photo lands is the caller's decision, and for health data that is the
  /// encrypted media store.
  Future<Uint8List> takePhoto();

  /// Releases the camera.
  Future<void> dispose();
}

/// [WoundCamera] on top of the `camera` plugin.
class PackageWoundCamera implements WoundCamera {
  CameraController? _controller;

  @override
  bool get isReady => _controller?.value.isInitialized ?? false;

  @override
  Future<CameraFailure?> start() async {
    final List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } on CameraException {
      return CameraFailure.unavailable;
    }
    if (cameras.isEmpty) return CameraFailure.unavailable;

    final back = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    // The preview is a framing aid, not the picture: a lower preview
    // resolution keeps the viewfinder smooth on the older phones in the field
    // while the photo itself is taken at the camera's own resolution.
    final controller = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
    } on CameraException catch (error) {
      await controller.dispose();
      return error.code == 'CameraAccessDenied'
          ? CameraFailure.denied
          : CameraFailure.failed;
    }

    _controller = controller;
    return null;
  }

  @override
  Widget preview() => CameraPreview(_controller!);

  @override
  Future<Uint8List> takePhoto() async {
    final file = await _controller!.takePicture();
    final bytes = await file.readAsBytes();

    // The plugin drops the picture into a temporary file on the way out. That
    // file is unencrypted health data, so it goes as soon as the bytes are in
    // hand; the encrypted store is the only place the photo stays.
    final temporary = File(file.path);
    if (temporary.existsSync()) await temporary.delete();

    return bytes;
  }

  @override
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }
}
