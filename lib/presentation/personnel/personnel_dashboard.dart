// lib/presentation/personnel/personnel_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:depron_app/data/services/auth_service.dart';
import 'package:depron_app/data/services/data_service.dart';
import 'package:depron_app/presentation/shared/map_widget.dart';
import 'package:depron_app/presentation/personnel/chart_widget.dart';

class PersonnelDashboard extends StatelessWidget {
  const PersonnelDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 💡 الحصول على خدمة المصادقة لتمكين تسجيل الخروج
    final authService = Provider.of<AuthService>(context, listen: false);
    // 💡 الحصول على خدمة البيانات لعرض حالة الاتصال
    final dataService = Provider.of<DataService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personnel Kontrol Paneli (Tam)',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color.fromARGB(255, 68, 6, 139), // لون مميز للموظف
        actions: [
          // 💡 زر عرض حالة اتصال قاعدة البيانات
          StreamBuilder<String>(
            stream: dataService.connectionStatusStream,
            initialData: 'Checking...',
            builder: (context, snapshot) {
              // عرض الحالة كنص صغير أو كرمز
              final isConnected = snapshot.data?.contains('Connected') ?? false;
              return Tooltip(
                message: 'DB Status: ${snapshot.data}',
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: isConnected ? Colors.lightGreenAccent : Colors.white70,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          
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
      // 📌 المحتوى: الخريطة والرسوم البيانية
      // ----------------------------------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Merhaba Personel! Deprem Analiz Verileri:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            
            // 1. الخريطة (يجب أن تأخذ ارتفاعًا واضحًا)
            const Text(
              '1. Bölgesel Analiz Haritası:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Container(
              height: 400, // تحديد ارتفاع ثابت للخريطة
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              // 💡 المكون الأساسي للخريطة (للموظف: true)
              child: const MapWidget(isPersonnel: true),
            ),
            
            const Divider(height: 30),
            
            // 2. الرسوم البيانية (Human Count Chart)
            const Text(
              '2. Yoğunluk Grafiği (Human Count):',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Container(
              height: 300, // تحديد ارتفاع ثابت للرسم البياني
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              // 💡 المكون الأساسي للرسوم البيانية
              child: ChartWidget(),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}