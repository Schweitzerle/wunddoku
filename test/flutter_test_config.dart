import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled font before any test runs.
///
/// Without this every golden renders in the test framework's placeholder
/// font — solid blocks instead of glyphs. That is enough to catch a layout
/// shift, but not enough to judge a screen: wording, weight and line breaks
/// are exactly what a design review looks at, and they are invisible in
/// blocks. With the real font a golden is a screenshot one can read.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final loader = FontLoader('Geist')
    ..addFont(
      File('assets/fonts/Geist.ttf').readAsBytes().then(
        (bytes) => ByteData.view(Uint8List.fromList(bytes).buffer),
      ),
    );
  await loader.load();

  // Material's own icon font, so a golden shows icons instead of boxes.
  final icons = Platform.environment['FLUTTER_ROOT'] == null
      ? null
      : File(
          '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/'
          'material_fonts/MaterialIcons-Regular.otf',
        );
  if (icons != null && icons.existsSync()) {
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(
        icons.readAsBytes().then(
          (bytes) => ByteData.view(Uint8List.fromList(bytes).buffer),
        ),
      );
    await iconLoader.load();
  }

  await testMain();
}
