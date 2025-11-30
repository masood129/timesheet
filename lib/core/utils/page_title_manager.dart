import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class PageTitleManager {
  static final PageTitleManager _instance = PageTitleManager._internal();
  factory PageTitleManager() => _instance;
  PageTitleManager._internal();

  static const String _baseTitle = 'تایم‌شیت';

  /// Set the page title with optional subtitle
  static void setTitle(String subtitle) {
    final fullTitle = subtitle.isNotEmpty 
        ? '$_baseTitle - $subtitle' 
        : _baseTitle;
    
    if (kIsWeb) {
      js.context['document']['title'] = fullTitle;
    }
  }

  /// Reset to base title
  static void resetTitle() {
    setTitle('');
  }
}

