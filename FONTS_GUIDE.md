# راهنمای استفاده از فونت‌ها / Font Usage Guide

## فونت‌های موجود / Available Fonts

### فونت فارسی / Persian Font
- **BNazanin**: فونت فارسی زیبا و خوانا برای متن‌های فارسی

### فونت‌های انگلیسی / English Fonts
- **Roboto**: فونت مدرن و حرفه‌ای گوگل (Regular, Bold, Italic)
- **Ubuntu**: فونت زیبا و خوانا (Regular, Bold, Italic)

## نحوه استفاده / How to Use

### 1. استفاده در Theme (توصیه می‌شود)

برای استفاده از فونت‌ها در کل اپلیکیشن، می‌توانید آن‌ها را در `ThemeData` تنظیم کنید:

```dart
MaterialApp(
  theme: ThemeData(
    fontFamily: 'BNazanin', // فونت پیش‌فرض برای فارسی
    textTheme: TextTheme(
      // می‌توانید فونت‌های مختلف را برای استایل‌های مختلف تنظیم کنید
      bodyLarge: TextStyle(fontFamily: 'BNazanin'),
      bodyMedium: TextStyle(fontFamily: 'BNazanin'),
      titleLarge: TextStyle(fontFamily: 'BNazanin', fontWeight: FontWeight.bold),
    ),
  ),
)
```

### 2. استفاده در ویجت‌های خاص

برای استفاده از فونت در یک ویجت خاص:

```dart
// فونت فارسی
Text(
  'سلام دنیا',
  style: TextStyle(
    fontFamily: 'BNazanin',
    fontSize: 16,
  ),
)

// فونت انگلیسی Roboto
Text(
  'Hello World',
  style: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.bold, // برای Bold
  ),
)

// فونت انگلیسی Ubuntu
Text(
  'Hello World',
  style: TextStyle(
    fontFamily: 'Ubuntu',
    fontSize: 16,
    fontStyle: FontStyle.italic, // برای Italic
  ),
)
```

### 3. استفاده ترکیبی (فارسی و انگلیسی)

برای متن‌هایی که هم فارسی و هم انگلیسی دارند:

```dart
Text(
  'سلام Hello دنیا World',
  style: TextStyle(
    fontFamily: 'BNazanin', // فونت اصلی
    fontSize: 16,
  ),
)
```

## نکات مهم / Important Notes

⚠️ **استفاده بدون اینترنت**: این پروژه برای اجرا در محیط بدون اینترنت طراحی شده است. تمام فونت‌ها به صورت محلی در پوشه `assets/fonts/` قرار دارند و نیازی به دانلود آنلاین ندارند.

1. **استفاده در TextField**:

```dart
TextField(
  style: TextStyle(fontFamily: 'BNazanin'),
  decoration: InputDecoration(
    labelStyle: TextStyle(fontFamily: 'BNazanin'),
    hintStyle: TextStyle(fontFamily: 'BNazanin'),
  ),
)
```

3. **وزن‌های مختلف فونت**:
   - `FontWeight.normal` یا `FontWeight.w400`: Regular
   - `FontWeight.bold` یا `FontWeight.w700`: Bold

4. **استایل‌های مختلف**:
   - `FontStyle.normal`: حالت عادی
   - `FontStyle.italic`: حالت کج (Italic)

## مثال کامل / Complete Example

```dart
import 'package:flutter/material.dart';

class FontExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'نمونه فونت‌ها',
          style: TextStyle(fontFamily: 'BNazanin'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // فارسی با BNazanin
            Text(
              'این یک متن فارسی است',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'BNazanin',
                fontSize: 18,
              ),
            ),
            SizedBox(height: 16),
            
            // انگلیسی با Roboto
            Text(
              'This is English text with Roboto',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            
            // انگلیسی Bold
            Text(
              'This is Bold Roboto',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            
            // انگلیسی Italic
            Text(
              'This is Italic Roboto',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 16),
            
            // Ubuntu
            Text(
              'This is Ubuntu font',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## فایل‌های فونت / Font Files

فونت‌ها در مسیر زیر قرار دارند:
- `assets/fonts/BNAZANIN.ttf` - فونت فارسی
- `assets/fonts/Roboto-Regular.ttf` - Roboto عادی
- `assets/fonts/Roboto-Bold.ttf` - Roboto Bold
- `assets/fonts/Roboto-Italic.ttf` - Roboto Italic
- `assets/fonts/Ubuntu-Regular.ttf` - Ubuntu عادی
- `assets/fonts/Ubuntu-Bold.ttf` - Ubuntu Bold
- `assets/fonts/Ubuntu-Italic.ttf` - Ubuntu Italic

## فونت‌های فارسی پیشنهادی برای اضافه کردن / Recommended Persian Fonts

اگر می‌خواهید فونت‌های فارسی بیشتری اضافه کنید:

### 1. Vazir Font
- **ویژگی**: مدرن، خوانا، سبک
- **مناسب برای**: متون عادی، رابط کاربری
- **دانلود**: https://github.com/rastikerdar/vazir-font/releases

### 2. IRANSans
- **ویژگی**: حرفه‌ای، زیبا
- **مناسب برای**: عناوین، متون رسمی
- **دانلود**: https://github.com/rastikerdar/iran-sans/releases

### 3. Yekan
- **ویژگی**: خوانایی بالا، مناسب صفحه نمایش
- **مناسب برای**: عناوین، دکمه‌ها

### نحوه افزودن فونت جدید:

1. فایل `.ttf` فونت را دانلود کنید
2. فایل را در `assets/fonts/` کپی کنید
3. در `pubspec.yaml` فونت را اضافه کنید:

```yaml
fonts:
  - family: Vazir
    fonts:
      - asset: assets/fonts/Vazir-Regular.ttf
      - asset: assets/fonts/Vazir-Bold.ttf
        weight: 700
```

4. دستور `flutter pub get` را اجرا کنید
5. در کد از فونت استفاده کنید:

```dart
Text(
  'متن با فونت وزیر',
  style: TextStyle(fontFamily: 'Vazir'),
)
```

## راهنمای کامل استفاده بدون اینترنت

برای اطلاعات کامل درباره استفاده از فونت‌ها در محیط بدون اینترنت، به فایل `OFFLINE_FONTS_GUIDE.md` مراجعه کنید.
