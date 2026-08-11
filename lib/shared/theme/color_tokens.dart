import 'package:flutter/material.dart';

/// Semantic colours Material does not know about.
///
/// The palette follows `docs/ux/tokens.md`: colour is a trust statement in
/// this app. Only two saturated colours carry state — red for "decide",
/// amber for "check". Certainty is the normal case and stays colourless.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.entscheiden,
    required this.pruefen,
    required this.sicher,
    required this.luecke,
    required this.offline,
    required this.mediaGround,
  });

  /// Low confidence: highlighted, blocks saving.
  final Color entscheiden;

  /// Medium confidence: marked, a look is recommended.
  final Color pruefen;

  /// High confidence — deliberately the plain text colour.
  final Color sicher;

  /// A gap: dashed outline, no value. Colourless on purpose.
  final Color luecke;

  /// Offline is the normal state, not an error — neutral.
  final Color offline;

  /// The ground behind wound photos.
  ///
  /// Identical in both themes: the tissue assessment distinguishes four
  /// colour impressions, and a surround that changes with the theme would
  /// shift that perception between day and night shifts.
  final Color mediaGround;

  static const light = StatusColors(
    entscheiden: Color(0xFFB3261E),
    pruefen: Color(0xFF8A5A00),
    sicher: Color(0xFF16181A),
    luecke: Color(0xFF7A7E82),
    offline: Color(0xFF4A4E52),
    mediaGround: Color(0xFF3A3D40),
  );

  static const dark = StatusColors(
    entscheiden: Color(0xFFF2B8B5),
    pruefen: Color(0xFFF5C46B),
    sicher: Color(0xFFE6E8EA),
    luecke: Color(0xFF8A8E92),
    offline: Color(0xFFB4B8BC),
    mediaGround: Color(0xFF3A3D40),
  );

  @override
  StatusColors copyWith({
    Color? entscheiden,
    Color? pruefen,
    Color? sicher,
    Color? luecke,
    Color? offline,
    Color? mediaGround,
  }) => StatusColors(
    entscheiden: entscheiden ?? this.entscheiden,
    pruefen: pruefen ?? this.pruefen,
    sicher: sicher ?? this.sicher,
    luecke: luecke ?? this.luecke,
    offline: offline ?? this.offline,
    mediaGround: mediaGround ?? this.mediaGround,
  );

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      entscheiden: Color.lerp(entscheiden, other.entscheiden, t)!,
      pruefen: Color.lerp(pruefen, other.pruefen, t)!,
      sicher: Color.lerp(sicher, other.sicher, t)!,
      luecke: Color.lerp(luecke, other.luecke, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
      mediaGround: Color.lerp(mediaGround, other.mediaGround, t)!,
    );
  }
}
