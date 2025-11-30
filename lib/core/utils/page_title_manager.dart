import 'page_title_manager_stub.dart'
    if (dart.library.html) 'page_title_manager_web.dart';

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
    
    setDocumentTitle(fullTitle);
  }

  /// Reset to base title
  static void resetTitle() {
    setTitle('');
  }
}

