import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A field phone, in logical pixels.
///
/// The devices in the tour are ordinary Android phones held in one hand.
const phoneSize = Size(390, 844);

/// The narrow end the layout still has to carry.
///
/// Small phones and large system font together land here, and it is the width
/// the rules name as the lower bound (`22-design-tokens.md`).
const narrowSize = Size(320, 700);

/// Renders the next goldens at [size] instead of the test binding's default.
///
/// Without this a golden is taken at 800×600 — wider than a tablet in
/// portrait. Line breaks, truncation and how full a screen looks are exactly
/// what a design review judges, and all three change with the width, so a
/// golden at the wrong size answers a question nobody asked.
Future<void> useScreen(
  WidgetTester tester, {
  Size size = phoneSize,
  double pixelRatio = 3,
}) async {
  tester.view.physicalSize = size * pixelRatio;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
