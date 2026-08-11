import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wunddoku/data/media/wound_camera.dart';

/// A camera that never touches hardware.
///
/// The screen around the viewfinder — framing aid, shutter, review, and every
/// way the camera can stay dark — is the part that carries the design, and it
/// is exactly the part a device test cannot check reproducibly.
class FakeCamera implements WoundCamera {
  FakeCamera({this.failure, this.photo});

  /// What [start] reports; `null` starts successfully.
  CameraFailure? failure;

  /// What [takePhoto] returns.
  Uint8List? photo;

  int starts = 0;
  int shots = 0;
  bool disposed = false;

  @override
  bool get isReady => failure == null && starts > 0;

  @override
  Future<CameraFailure?> start() async {
    starts++;
    return failure;
  }

  @override
  Widget preview() => const ColoredBox(
    color: Color(0xFF102030),
    child: SizedBox.expand(child: Text('viewfinder')),
  );

  @override
  Future<Uint8List> takePhoto() async {
    shots++;
    final bytes = photo;
    if (bytes == null) throw const _ShutterFailed();
    return bytes;
  }

  @override
  Future<void> dispose() async => disposed = true;
}

class _ShutterFailed implements Exception {
  const _ShutterFailed();
}
