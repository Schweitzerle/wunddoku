import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/id_generator.dart';

/// What a stored file holds.
///
/// The kind decides the retention rule, not the storage: an audio recording is
/// raw material that goes once its transcript is confirmed, a photo belongs to
/// the record.
enum MediaKind {
  /// A wound photo as the camera took it.
  photo,

  /// A wound photo with the outline burnt in.
  markedPhoto,

  /// A voice recording made during capture.
  audio,
}

/// A handle to one stored file.
///
/// The name is generated, never derived from anything the patient said or the
/// camera supplied: a file name is metadata that survives in backups and file
/// listings, so it must not carry content.
extension type const MediaRef(String name) {
  /// Whether [name] could have come from [MediaStore.save].
  ///
  /// Guards the path against traversal: a ref that reached the app from
  /// outside must never resolve to a file elsewhere on the device.
  bool get isWellFormed => RegExp(r'^[a-z]+_[a-z0-9]+\.bin$').hasMatch(name);
}

/// Stores media as encrypted files.
///
/// Photos and recordings of a wound are health data in their own right, so
/// they are encrypted at rest and kept in the app's own directory — never in
/// the system gallery, never in a cloud backup.
abstract interface class MediaStore {
  /// Writes [bytes] and returns the handle to read them back with.
  Future<MediaRef> save(Uint8List bytes, {required MediaKind kind});

  /// The plaintext behind [ref].
  ///
  /// Throws [MediaUnavailable] when the file is gone, and [MediaTampered] when
  /// it no longer authenticates.
  Future<Uint8List> read(MediaRef ref);

  /// Removes the file behind [ref].
  ///
  /// Deleting something that is already gone is not an error: the deletion
  /// path has to be repeatable, otherwise a half-finished wipe cannot be
  /// completed.
  Future<void> delete(MediaRef ref);
}

/// The file behind a reference is missing.
class MediaUnavailable implements Exception {
  const MediaUnavailable(this.ref);

  final MediaRef ref;

  @override
  String toString() => 'MediaUnavailable(${ref.name})';
}

/// The file behind a reference failed its authentication check.
///
/// With AES-GCM this means the bytes were changed after they were written —
/// the content is not shown, because a wound photo that cannot be trusted is
/// worse than none.
class MediaTampered implements Exception {
  const MediaTampered(this.ref);

  final MediaRef ref;

  @override
  String toString() => 'MediaTampered(${ref.name})';
}

/// [MediaStore] backed by AES-GCM-256 encrypted files.
///
/// Layout of a file: a 12-byte nonce, the ciphertext, then the 16-byte MAC.
/// Everything needed to decrypt except the key travels with the file, so a
/// single file can be read without an index.
class EncryptedMediaStore implements MediaStore {
  EncryptedMediaStore({
    required Directory directory,
    required SecretKey key,
    Random? random,
  }) : _directory = directory,
       _key = key,
       _random = random;

  /// Length of the AES-GCM nonce in bytes; the algorithm's own default.
  static const _nonceLength = 12;

  /// Length of the AES-GCM authentication tag in bytes.
  static const _macLength = 16;

  final Directory _directory;
  final SecretKey _key;

  /// Injected in tests so a file name is reproducible; production uses
  /// [Random.secure] via [newId].
  final Random? _random;
  final _algorithm = AesGcm.with256bits();

  /// Derives the media key from [databaseKey].
  ///
  /// Separate key material for a separate purpose: the database key stays the
  /// database's, so a media key that ever leaks does not open the record.
  static Future<SecretKey> deriveKey(String databaseKey) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    return hkdf.deriveKey(
      secretKey: SecretKey(Uint8List.fromList(databaseKey.codeUnits)),
      info: 'wunddoku.media.v1'.codeUnits,
      nonce: const <int>[],
    );
  }

  @override
  Future<MediaRef> save(Uint8List bytes, {required MediaKind kind}) async {
    final ref = MediaRef(
      '${kind.name.toLowerCase()}_${newId(random: _random)}.bin',
    );
    final box = await _algorithm.encrypt(bytes, secretKey: _key);

    await _directory.create(recursive: true);
    await _file(ref).writeAsBytes([
      ...box.nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ], flush: true);
    return ref;
  }

  @override
  Future<Uint8List> read(MediaRef ref) async {
    final file = _file(ref);
    if (!file.existsSync()) throw MediaUnavailable(ref);

    final stored = await file.readAsBytes();
    if (stored.length < _nonceLength + _macLength) throw MediaTampered(ref);

    final box = SecretBox(
      stored.sublist(_nonceLength, stored.length - _macLength),
      nonce: stored.sublist(0, _nonceLength),
      mac: Mac(stored.sublist(stored.length - _macLength)),
    );

    try {
      return Uint8List.fromList(await _algorithm.decrypt(box, secretKey: _key));
    } on SecretBoxAuthenticationError {
      throw MediaTampered(ref);
    }
  }

  @override
  Future<void> delete(MediaRef ref) async {
    final file = _file(ref);
    if (file.existsSync()) await file.delete();
  }

  File _file(MediaRef ref) {
    if (!ref.isWellFormed) throw MediaUnavailable(ref);
    return File('${_directory.path}/${ref.name}');
  }
}

/// The directory media files live in.
///
/// Application support, not documents and not the cache: the operating system
/// leaves it out of user-visible file listings, and unlike the cache it is not
/// cleared under memory pressure — a wound photo taken offline has to survive
/// until the visit is closed.
Future<Directory> defaultMediaDirectory() async {
  final base = await getApplicationSupportDirectory();
  return Directory('${base.path}/media');
}
