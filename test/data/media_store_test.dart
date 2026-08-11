import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/media/media_store.dart';

void main() {
  late Directory directory;
  late EncryptedMediaStore store;

  /// Stands in for a photo: a PNG header plus a recognisable body.
  final photo = Uint8List.fromList([
    137, 80, 78, 71, 13, 10, 26, 10, // PNG magic number
    ...List<int>.generate(2048, (i) => i % 251),
  ]);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('wunddoku_media');
    store = EncryptedMediaStore(
      directory: directory,
      key: await EncryptedMediaStore.deriveKey('a' * 64),
    );
  });

  tearDown(() async {
    if (directory.existsSync()) await directory.delete(recursive: true);
  });

  test('what comes back is what went in', () async {
    final ref = await store.save(photo, kind: MediaKind.photo);
    expect(await store.read(ref), photo);
  });

  test('what lies on the device is not the photo', () async {
    final ref = await store.save(photo, kind: MediaKind.photo);
    final onDisk = await File('${directory.path}/${ref.name}').readAsBytes();

    // The visible proof of encryption at rest: no PNG signature, and none of
    // the original run of bytes anywhere in the file.
    expect(
      onDisk.sublist(0, 8),
      isNot([137, 80, 78, 71, 13, 10, 26, 10]),
      reason: 'a readable PNG header would mean the file is plaintext',
    );
    expect(_contains(onDisk, photo.sublist(64, 128)), isFalse);
    expect(onDisk.length, greaterThan(photo.length));
  });

  test('two files with the same content look different', () async {
    final first = await store.save(photo, kind: MediaKind.photo);
    final second = await store.save(photo, kind: MediaKind.photo);

    final a = await File('${directory.path}/${first.name}').readAsBytes();
    final b = await File('${directory.path}/${second.name}').readAsBytes();

    // A fresh nonce per file. Without it, two photos of the same wound would
    // be recognisable as identical without any key.
    expect(a, isNot(b));
    expect(first.name, isNot(second.name));
  });

  test('a changed file is refused rather than shown', () async {
    final ref = await store.save(photo, kind: MediaKind.photo);
    final file = File('${directory.path}/${ref.name}');
    final bytes = await file.readAsBytes();
    bytes[40] ^= 0xFF;
    await file.writeAsBytes(bytes, flush: true);

    // A wound photo that cannot be trusted is worse than none: the report
    // would carry it as a finding.
    await expectLater(store.read(ref), throwsA(isA<MediaTampered>()));
  });

  test('a truncated file is refused too', () async {
    final ref = await store.save(photo, kind: MediaKind.photo);
    final file = File('${directory.path}/${ref.name}');
    await file.writeAsBytes([1, 2, 3], flush: true);

    await expectLater(store.read(ref), throwsA(isA<MediaTampered>()));
  });

  test('another key does not open the file', () async {
    final ref = await store.save(photo, kind: MediaKind.photo);
    final other = EncryptedMediaStore(
      directory: directory,
      key: await EncryptedMediaStore.deriveKey('b' * 64),
    );

    await expectLater(other.read(ref), throwsA(isA<MediaTampered>()));
  });

  test('the media key is not the database key', () async {
    final databaseKey = 'c' * 64;
    final derived = await EncryptedMediaStore.deriveKey(databaseKey);

    expect(
      await derived.extractBytes(),
      isNot(Uint8List.fromList(databaseKey.codeUnits)),
    );
    expect(await derived.extractBytes(), hasLength(32));
  });

  group('deletion', () {
    test('removes the file from the device', () async {
      final ref = await store.save(photo, kind: MediaKind.photo);
      await store.delete(ref);

      expect(File('${directory.path}/${ref.name}').existsSync(), isFalse);
      await expectLater(store.read(ref), throwsA(isA<MediaUnavailable>()));
    });

    test('deleting twice is not an error', () async {
      final ref = await store.save(photo, kind: MediaKind.audio);
      await store.delete(ref);

      // A wipe that stops halfway has to be resumable.
      await expectLater(store.delete(ref), completes);
    });
  });

  group('references', () {
    test('a name from outside cannot point out of the directory', () async {
      const escape = MediaRef('../../../etc/passwd');
      expect(escape.isWellFormed, isFalse);
      await expectLater(store.read(escape), throwsA(isA<MediaUnavailable>()));
      await expectLater(store.delete(escape), throwsA(isA<MediaUnavailable>()));
    });

    test('a generated name says nothing about the content', () async {
      final ref = await store.save(photo, kind: MediaKind.markedPhoto);

      // File names survive in backups and listings, so they carry the kind at
      // most — never a patient, a wound or a date.
      expect(ref.isWellFormed, isTrue);
      expect(ref.name, startsWith('markedphoto_'));
      expect(ref.name, matches(RegExp(r'^markedphoto_[0-9a-f]{32}\.bin$')));
    });
  });
}

/// Whether [haystack] contains [needle] as a run of bytes.
bool _contains(List<int> haystack, List<int> needle) {
  for (var i = 0; i + needle.length <= haystack.length; i++) {
    var hit = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        hit = false;
        break;
      }
    }
    if (hit) return true;
  }
  return false;
}
