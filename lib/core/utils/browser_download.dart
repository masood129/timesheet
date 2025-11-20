import 'dart:typed_data';

import 'browser_download_stub.dart'
    if (dart.library.html) 'browser_download_web.dart';

Future<String?> triggerBrowserDownload(
  Uint8List bytes,
  String fileName,
) {
  return browserDownload(bytes, fileName);
}

