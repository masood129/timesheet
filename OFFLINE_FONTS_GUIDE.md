# راهنمای استفاده از فونت‌ها در محیط بدون اینترنت
# Offline Fonts Usage Guide

## 📋 وضعیت فعلی / Current Status

✅ **آماده برای استفاده بدون اینترنت** - تمام فونت‌های مورد نیاز به صورت محلی در پروژه موجود است.

### فونت‌های نصب شده / Installed Fonts

#### 🇮🇷 فونت فارسی
- **BNazanin** (BNAZANIN.ttf)
  - فونت اصلی و پیش‌فرض برنامه
  - مناسب برای متون فارسی
  - پشتیبانی کامل از زبان فارسی

#### 🇬🇧 فونت‌های انگلیسی
- **Roboto** (Regular, Bold, Italic)
  - فونت مدرن و حرفه‌ای
  - مناسب برای متون انگلیسی و اعداد
  
- **Ubuntu** (Regular, Bold, Italic)
  - فونت خوانا و زیبا
  - مناسب برای رابط کاربری

## ⚙️ تنظیمات انجام شده / Configuration Done

### 1. تنظیمات pubspec.yaml
```yaml
flutter:
  assets:
    - assets/fonts/  # ✅ اضافه شده
  
  fonts:
    - family: BNazanin
      fonts:
        - asset: assets/fonts/BNAZANIN.ttf
    
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
        - asset: assets/fonts/Roboto-Italic.ttf
          style: italic
    
    - family: Ubuntu
      fonts:
        - asset: assets/fonts/Ubuntu-Regular.ttf
        - asset: assets/fonts/Ubuntu-Bold.ttf
          weight: 700
        - asset: assets/fonts/Ubuntu-Italic.ttf
          style: italic
```

### 2. تنظیمات Theme
فونت BNazanin به عنوان فونت پیش‌فرض در `lib/core/theme/theme.dart` تنظیم شده است:

```dart
// در theme.dart
class FontConfig {
  static const String persianFont = 'BNazanin';
  static const String englishFont = 'Ubuntu';
}

ThemeData mainTheme = ThemeData(
  fontFamily: FontConfig.persianFont, // فونت پیش‌فرض
  // ...
);
```

## 📦 افزودن فونت جدید / Adding New Fonts

اگر نیاز به افزودن فونت جدید دارید (مثلاً Vazir، IRANSans، Yekan):

### مرحله 1: دانلود فونت
فایل‌های `.ttf` یا `.otf` فونت مورد نظر را دانلود کنید.

### مرحله 2: کپی به پروژه
```
assets/
  fonts/
    - BNAZANIN.ttf
    - Roboto-*.ttf
    - Ubuntu-*.ttf
    + YOUR_NEW_FONT.ttf  ← فایل جدید
```

### مرحله 3: تنظیم pubspec.yaml
```yaml
fonts:
  # فونت‌های موجود...
  
  - family: YourFontName
    fonts:
      - asset: assets/fonts/YOUR_NEW_FONT.ttf
      - asset: assets/fonts/YOUR_NEW_FONT-Bold.ttf
        weight: 700
```

### مرحله 4: اجرای دستور
```bash
flutter pub get
flutter clean
flutter run
```

## 🎨 استفاده از فونت‌ها / Using Fonts

### استفاده در کد
```dart
// فونت فارسی
Text(
  'متن فارسی',
  style: TextStyle(fontFamily: 'BNazanin'),
)

// فونت انگلیسی
Text(
  'English Text',
  style: TextStyle(fontFamily: 'Ubuntu'),
)

// استفاده از Theme
Text(
  'متن با استفاده از Theme',
  style: Theme.of(context).textTheme.bodyLarge,
)
```

### استفاده از FontConfig
```dart
import 'package:timesheet/core/theme/theme.dart';

Text(
  'متن فارسی',
  style: TextStyle(
    fontFamily: FontConfig.persianFont,
    fontSize: FontConfig.fontSizeBodyLarge,
    fontWeight: FontConfig.fontWeightNormal,
  ),
)
```

## 🔍 بررسی مشکلات / Troubleshooting

### مشکل: فونت نمایش داده نمی‌شود
✅ **راه‌حل:**
1. `flutter clean` را اجرا کنید
2. `flutter pub get` را اجرا کنید
3. برنامه را دوباره اجرا کنید

### مشکل: فونت فارسی به درستی نمایش داده نمی‌شود
✅ **راه‌حل:**
```dart
Text(
  'متن فارسی',
  textDirection: TextDirection.rtl,  // اضافه کنید
  style: TextStyle(fontFamily: 'BNazanin'),
)
```

### مشکل: فونت Bold کار نمی‌کند
✅ **راه‌حل:**
اطمینان حاصل کنید که در `pubspec.yaml` وزن فونت تنظیم شده:
```yaml
- asset: assets/fonts/FONT-Bold.ttf
  weight: 700  # این خط الزامی است
```

## 🌐 فونت‌های فارسی پیشنهادی برای اضافه کردن

### Vazir
- **مزایا:** خوانایی عالی، سبک و مدرن
- **دانلود:** https://github.com/rastikerdar/vazir-font/releases

### IRANSans
- **مزایا:** طراحی حرفه‌ای، مناسب رابط‌های کاربری
- **دانلود:** https://github.com/rastikerdar/iran-sans/releases

### Samim
- **مزایا:** زیبا و خوانا
- **دانلود:** https://github.com/rastikerdar/samim-font/releases

### Yekan
- **مزایا:** خوانایی بالا، مناسب عناوین
- **دانلود:** https://fontlibrary.org/en/font/byekan

## 📝 نکات مهم / Important Notes

1. **حجم فایل**: هر فایل فونت حدود 100-500 KB حجم دارد. تعداد فونت‌ها را محدود نگه دارید.

2. **کش فونت**: فلاتر فونت‌ها را کش می‌کند، بنابراین بعد از اولین بار نیازی به دانلود مجدد نیست.

3. **تست کامل**: قبل از استقرار، تمام فونت‌ها را در دستگاه‌های مختلف تست کنید:
   ```bash
   flutter run -d android
   flutter run -d ios
   flutter run -d web
   flutter run -d windows
   ```

4. **Fallback Font**: اگر فونتی یافت نشد، فلاتر به فونت پیش‌فرض سیستم برمی‌گردد.

5. **بهینه‌سازی برای موبایل**: 
   - از فونت‌های سبک استفاده کنید
   - فقط وزن‌های مورد نیاز را اضافه کنید
   - حجم APK/IPA را در نظر بگیرید

## 📱 تست در دستگاه‌های مختلف

### Android
```bash
flutter build apk
# یا
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

## ✅ چک‌لیست نهایی / Final Checklist

- [x] فونت‌ها در assets/fonts/ موجود هستند
- [x] pubspec.yaml به درستی تنظیم شده
- [x] assets/fonts/ به بخش assets اضافه شده
- [x] Theme از فونت‌های محلی استفاده می‌کند
- [x] FontConfig برای مدیریت یکپارچه فونت‌ها موجود است
- [x] تمام وابستگی‌ها محلی هستند
- [x] هیچ وابستگی آنلاین به google_fonts یا سرویس‌های دیگر نیست

## 🚀 آماده برای استقرار / Ready for Deployment

برنامه شما اکنون کاملاً بدون نیاز به اینترنت قابل اجرا است! 🎉

### مزایای استفاده آفلاین:
1. ✅ **سرعت بالاتر** - بدون تاخیر دانلود فونت
2. ✅ **مصرف کمتر داده** - بدون نیاز به اینترنت
3. ✅ **قابلیت اطمینان** - کار در محیط‌های بدون اینترنت
4. ✅ **امنیت بیشتر** - عدم وابستگی به سرورهای خارجی
5. ✅ **تجربه کاربری بهتر** - بدون تاخیر در بارگذاری فونت‌ها

---

**تاریخ آخرین به‌روزرسانی:** 2026-01-29
**نسخه:** 1.0.0
**پروژه:** Timesheet Mobile App
