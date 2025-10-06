// lib/presentation/user/limited_map_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:depron_app/data/services/auth_service.dart';
import 'package:depron_app/presentation/shared/map_widget.dart';

class LimitedMapView extends StatelessWidget {
  const LimitedMapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 💡 نحصل على خدمة المصادقة لتمكين تسجيل الخروج (مطلوب)
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'İnsani Yardım Haritası', // خريطة المساعدة الإنسانية
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.green, // لون مميز للمستخدم العادي
        actions: [
          // 💡 زر تسجيل الخروج
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      
      // ----------------------------------------------------
      // 📌 المحتوى: الخريطة فقط
      // ----------------------------------------------------
      body: 
      // 💡 هنا يجب أن نعرض MapWidget.
      // ملاحظة: لا نحتاج SingleChildScrollView لأن الخريطة هي المكون الوحيد.
      const MapWidget(
        isPersonnel: false, // 💡 هذا هو المفتاح: false تعني أنه مستخدم عادي
      ),
    );
  }
}