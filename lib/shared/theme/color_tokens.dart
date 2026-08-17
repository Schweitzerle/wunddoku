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
    required this.onMediaGround,
    required this.markPrevious,
  });

  /// Low confidence: highlighted, blocks saving.
  final Color entscheiden;

  /// Medium confidence: marked, a look is recommended.
  final Color pruefen;

  /// High confidence — deliberately the plain text colour.
  final Color sicher;

  /// A gap: dashed outline, no value. Colourless on purpose.
  ///
  /// Carries running text as well as outlines — the gap counts on the
  /// capture, closing and course screens — so it is held to the 4.5:1 text
  /// threshold, not the 3:1 one an outline would need.
  final Color luecke;

  /// Offline is the normal state, not an error — neutral.
  final Color offline;

  /// The ground behind wound photos.
  ///
  /// Identical in both themes: the tissue assessment distinguishes four
  /// colour impressions, and a surround that changes with the theme would
  /// shift that perception between day and night shifts.
  final Color mediaGround;

  /// The outline of the previous visit, drawn behind the current one.
  ///
  /// Identical in both themes, and outside the palette on purpose: it lies on
  /// a wound photo, has to be told apart from the current outline at a
  /// glance, and must never be mistaken for tissue. Magenta occurs in no
  /// wound.
  final Color markPrevious;

  /// Text and icons drawn on [mediaGround].
  ///
  /// Identical in both themes for the same reason the ground is: a label
  /// taken from the theme turns dark grey on dark grey in the light theme.
  final Color onMediaGround;

  static const light = StatusColors(
    entscheiden: Color(0xFFA32017),
    pruefen: Color(0xFF7A4E00),
    sicher: Color(0xFF1C1A17),
    luecke: Color(0xFF635D56),
    offline: Color(0xFF57514A),
    mediaGround: Color(0xFF3A3D40),
    onMediaGround: Color(0xFFE6E8EA),
    markPrevious: Color(0xFFFF00E5),
  );

  static const dark = StatusColors(
    entscheiden: Color(0xFFF2B8B5),
    pruefen: Color(0xFFEFC069),
    sicher: Color(0xFFE3EDEF),
    luecke: Color(0xFF8FA7AD),
    offline: Color(0xFFA9BFC4),
    mediaGround: Color(0xFF3A3D40),
    onMediaGround: Color(0xFFE6E8EA),
    markPrevious: Color(0xFFFF00E5),
  );

  @override
  StatusColors copyWith({
    Color? entscheiden,
    Color? pruefen,
    Color? sicher,
    Color? luecke,
    Color? offline,
    Color? mediaGround,
    Color? onMediaGround,
    Color? markPrevious,
  }) => StatusColors(
    entscheiden: entscheiden ?? this.entscheiden,
    pruefen: pruefen ?? this.pruefen,
    sicher: sicher ?? this.sicher,
    luecke: luecke ?? this.luecke,
    offline: offline ?? this.offline,
    mediaGround: mediaGround ?? this.mediaGround,
    onMediaGround: onMediaGround ?? this.onMediaGround,
    markPrevious: markPrevious ?? this.markPrevious,
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
      onMediaGround: Color.lerp(onMediaGround, other.onMediaGround, t)!,
      markPrevious: Color.lerp(markPrevious, other.markPrevious, t)!,
    );
  }
}
