// Entry point for agent-driven sessions only.
// Enables the Flutter Driver extension so tooling can screenshot, tap,
// enter text and hot reload. Never used for a release build.
import 'package:flutter_driver/driver_extension.dart';

import 'main.dart' as app;

void main() {
  enableFlutterDriverExtension();
  app.main();
}
