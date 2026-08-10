import 'dart:math';

/// Generates random identifiers for new records.
///
/// 16 bytes from [Random.secure], rendered as 32 hex characters. Random rather
/// than sequential on purpose: records are created offline on several devices,
/// so identifiers must not collide when data is merged later.
String newId({Random? random}) {
  final rng = random ?? Random.secure();
  final buffer = StringBuffer();
  for (var i = 0; i < 16; i++) {
    buffer.write(rng.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
