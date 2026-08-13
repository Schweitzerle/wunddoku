import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Reads the bytes behind a media handle, or null when the file no longer
/// reads.
typedef PhotoLoader = Future<Uint8List?> Function(String ref);

/// A wound photo, small, on the ground reserved for wound photos.
///
/// The ground follows neither theme (`mediaGround`): the tissue assessment
/// distinguishes four colour impressions, and a surround that changes between
/// day and night shifts would shift that perception.
class PhotoThumbnail extends StatelessWidget {
  const PhotoThumbnail({
    required this.ref,
    required this.loadPhoto,
    required this.noPhotoLabel,
    required this.missingLabel,
    this.size = 72,
    super.key,
  });

  /// Handle of the photo, or null when the visit has none.
  final String? ref;

  final PhotoLoader loadPhoto;

  /// Stands in the box when there is no photo at all.
  final String noPhotoLabel;

  /// Stands in the box when the file behind [ref] could not be read.
  final String missingLabel;

  /// Edge length in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final status = context.statusColors;
    final handle = ref;

    return ClipRRect(
      borderRadius: BorderRadius.circular(spacing.r8),
      child: SizedBox.square(
        dimension: size,
        child: ColoredBox(
          color: status.mediaGround,
          child: handle == null
              ? _Placeholder(icon: Icons.image_outlined, label: noPhotoLabel)
              : FutureBuilder<Uint8List?>(
                  future: loadPhoto(handle),
                  builder: (context, snapshot) => switch (snapshot) {
                    AsyncSnapshot(hasError: true) ||
                    AsyncSnapshot(
                      connectionState: ConnectionState.done,
                      data: null,
                    ) => _Placeholder(
                      icon: Icons.image_not_supported_outlined,
                      label: missingLabel,
                    ),
                    AsyncSnapshot(:final data?) => Image.memory(
                      data,
                      fit: BoxFit.cover,
                      // A wound photo is several times the size of this box;
                      // decoding it at full resolution for a thumbnail is
                      // memory a field phone does not have to spare.
                      cacheWidth:
                          (size * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                    ),
                    _ => const SizedBox.shrink(),
                  },
                ),
        ),
      ),
    );
  }
}

/// Stands in for a picture that is not there.
///
/// A mark rather than words: the box is 64 dp and does not grow with the
/// text, so at 200 % a caption inside it is cut off mid-word. The sentence
/// survives as the semantics label, where it is read out in full.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final status = context.statusColors;

    return Center(
      child: Icon(
        icon,
        size: 24,
        color: status.onMediaGround,
        semanticLabel: label,
      ),
    );
  }
}
