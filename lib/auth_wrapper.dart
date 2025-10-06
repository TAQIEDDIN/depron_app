//auth_wrapper.dart
import 'package:depron_app/presentation/user/limited_map_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:depron_app/data/services/auth_service.dart';
import 'data/models/user_model.dart'; 
import 'presentation/auth/splash_screen.dart'; // الشاشة الأولى
import 'presentation/user/limited_map_view.dart'; // للمستخدمين العاديين
import 'presentation/personnel/personnel_dashboard.dart'; // للموظفين/المنقذين

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. الاستماع إلى حالة المستخدم من AuthService
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      // 💡 تم تصحيح هذا السطر لاستخدام 'userChanges' بدلاً من 'user'
      stream: authService.userChanges, 
      builder: (context, snapshot) {
        // حالة التحميل الأولية
        if (snapshot.connectionState == ConnectionState.waiting) {
          // يمكن هنا عرض شاشة تحميل بسيطة أو SplashScreen
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2. إذا لم يسجل الدخول (null)
        final user = snapshot.data;
        if (user == null) {
          // 💡 إذا لم يسجل الدخول، نعرض شاشة الترحيب/الدخول
          return const SplashScreen(); 
        }

        // 3. إذا سجل الدخول بنجاح (user != null)
        // يجب جلب بيانات المستخدم لتحديد دوره
        return FutureBuilder<UserModel?>(
          future: authService.fetchUserModel(user.uid),
          builder: (context, userModelSnapshot) {
            // حالة التحميل أثناء جلب بيانات الدور
            if (userModelSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // 4. تحديد الدور والتوجيه
            final userModel = userModelSnapshot.data;
            if (userModel == null) {
                // حالة نادرة: تم التسجيل في Firebase لكن لا يوجد بيانات في Firestore
                // يجب تسجيل الخروج وإعادة التوجيه إلى صفحة الدخول
                authService.signOut();
                return const SplashScreen();
            }

            // التوجيه بناءً على الدور
            if (userModel.role == 'personnel') {
              // 💡 الموظف/المنقذ
              return const PersonnelDashboard();
            } else {
              // 💡 المستخدم العادي (User)
              return const LimitedMapView();
            }
          },
        );
      },
    );
  }
}
