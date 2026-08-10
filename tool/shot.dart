// Saves a screenshot of the running app to a PNG file.
// The app must run from lib/main_driver.dart so the driver extension is live.
//
//   dart run tool/shot.dart <vm-service-uri> [out.png]
//
// The MCP screenshot tool returns the image to the agent but never writes a
// file. Goldens, design reviews and handovers need files, so this script does
// the persisting part.
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run tool/shot.dart <vm-service-uri> [out.png]');
    exit(64);
  }
  final out = File(args.length > 1 ? args[1] : 'doc/screenshots/shot.png');
  final driver = await FlutterDriver.connect(dartVmServiceUrl: args.first);
  try {
    final bytes = await driver.screenshot();
    await out.parent.create(recursive: true);
    await out.writeAsBytes(bytes);
    stdout.writeln('saved ${out.path} (${bytes.length} bytes)');
  } finally {
    await driver.close();
  }
}
