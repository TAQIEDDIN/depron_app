import 'package:flutter/material.dart';

class AppColors {
  // 💡 اللون الأخضر الأساسي للعلامة التجارية (Brand Primary Color)
  // يستخدم كخلفية للشاشات الرئيسية والأشرطة العلوية.
  static const Color primaryGreen = Color(0xFF006633); 
  
  // 💡 لون أخضر أفتح للمسات الجمالية والأزرار الثانوية.
  static const Color secondaryGreen = Color(0xFF38A700);

  // 💡 لون فاتح جداً للخلفيات أو حقول الإدخال.
  static const Color lightBackground = Color(0xFFF7F7F7);

  // 💡 لون النص الأساسي (لأنه سيتم استخدامه فوق الخلفيات الفاتحة).
  static const Color primaryText = Color(0xFF333333);

  // 💡 لون النص الثانوي (للتفاصيل والوصف).
  static const Color secondaryText = Color(0xFF757575);

  // 💡 لون النص الأبيض (مهم فوق الخلفيات الخضراء الداكنة).
  static const Color white = Colors.white;

  // 💡 لون الأزرار والحالة النشطة (بناءً على الصورة الترحيبية).
  static const Color accentColor = Color(0xFF00CC00); // لون أخضر حيوي
}
