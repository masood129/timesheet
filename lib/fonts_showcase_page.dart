import 'package:flutter/material.dart';

/// صفحه نمایش نمونه فونت‌های موجود در اپلیکیشن
/// این صفحه برای تست و مشاهده فونت‌های مختلف استفاده می‌شود
class FontsShowcasePage extends StatelessWidget {
  const FontsShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'نمایش فونت‌ها',
          style: TextStyle(fontFamily: 'BNazanin'),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عنوان اصلی
            _buildSectionTitle('فونت فارسی - BNazanin'),
            const SizedBox(height: 16),

            // نمونه‌های فونت فارسی
            _buildFontCard(
              'BNazanin',
              'این یک متن نمونه به زبان فارسی است',
              'سلام! خوش آمدید به سیستم تایم‌شیت',
              TextDirection.rtl,
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('فونت انگلیسی - Roboto'),
            const SizedBox(height: 16),

            // نمونه‌های فونت Roboto
            _buildFontCard(
              'Roboto',
              'This is a sample text in English',
              'Hello! Welcome to the Timesheet System',
              TextDirection.ltr,
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('فونت انگلیسی - Ubuntu'),
            const SizedBox(height: 16),

            // نمونه‌های فونت Ubuntu
            _buildFontCard(
              'Ubuntu',
              'This is a sample text in English',
              'Hello! Welcome to the Timesheet System',
              TextDirection.ltr,
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('ترکیب فارسی و انگلیسی'),
            const SizedBox(height: 16),

            // نمونه ترکیبی
            _buildMixedFontCard(),

            const SizedBox(height: 24),
            _buildSectionTitle('اعداد و کاراکترهای خاص'),
            const SizedBox(height: 16),

            // نمونه اعداد
            _buildNumbersCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'BNazanin',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildFontCard(
    String fontFamily,
    String sampleText,
    String headerText,
    TextDirection direction,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نام فونت
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Font: $fontFamily',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 16),

            // متن بزرگ
            Text(
              headerText,
              textDirection: direction,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // متن عادی
            Text(
              sampleText,
              textDirection: direction,
              style: TextStyle(fontFamily: fontFamily, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // متن Bold
            Text(
              'Bold: $sampleText',
              textDirection: direction,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // متن Italic (فقط برای فونت‌های انگلیسی)
            if (fontFamily != 'BNazanin')
              Text(
                'Italic: $sampleText',
                textDirection: direction,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMixedFontCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'سلام Hello دنیا World!',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'BNazanin', fontSize: 20),
            ),
            const SizedBox(height: 12),
            const Text(
              'تاریخ: 1403/09/12 - Date: 2024/12/02',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'BNazanin', fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'User: کاربر - Time: ساعت 10:30',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'BNazanin', fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumbersCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اعداد فارسی
            const Text(
              'اعداد: ۰ ۱ ۲ ۳ ۴ ۵ ۶ ۷ ۸ ۹',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'BNazanin', fontSize: 18),
            ),
            const SizedBox(height: 12),

            // اعداد انگلیسی
            const Text(
              'Numbers: 0 1 2 3 4 5 6 7 8 9',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 18),
            ),
            const SizedBox(height: 12),

            // کاراکترهای خاص
            const Text(
              'Special: @ # \$ % & * ( ) - + = / \\ | [ ] { }',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
            ),
            const SizedBox(height: 12),

            // علائم نگارشی فارسی
            const Text(
              'علائم: ، . ؛ ؟ ! « » ( ) - + = / \\',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'BNazanin', fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
