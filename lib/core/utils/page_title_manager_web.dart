// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation for setting document title
void setDocumentTitle(String title) {
  html.document.title = title;
}

