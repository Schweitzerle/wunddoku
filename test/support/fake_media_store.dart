import 'dart:typed_data';

import 'package:wunddoku/data/media/media_store.dart';

/// A [MediaStore] that keeps files in memory.
///
/// The encryption itself is covered by `test/data/media_store_test.dart`
/// against real files; everything above it only needs save, read and delete
/// to behave, and in memory that runs in a widget test without a temporary
/// directory per case.
class FakeMediaStore implements MediaStore {
  final Map<String, Uint8List> files = {};
  int _counter = 0;

  @override
  Future<MediaRef> save(Uint8List bytes, {required MediaKind kind}) async {
    final ref = MediaRef('${kind.name.toLowerCase()}_${++_counter}.bin');
    files[ref.name] = bytes;
    return ref;
  }

  @override
  Future<Uint8List> read(MediaRef ref) async {
    final bytes = files[ref.name];
    if (bytes == null) throw MediaUnavailable(ref);
    return bytes;
  }

  @override
  Future<void> delete(MediaRef ref) async => files.remove(ref.name);
}
