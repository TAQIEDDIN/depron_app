import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/services/auth_service.dart';
import 'data/models/user_model.dart';
import 'presentation/auth/splash_screen.dart';
import 'presentation/user/limited_map_view.dart';
import 'presentation/personnel/personnel_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.userChanges,
      builder: (context, snapshot) {
        // 1️⃣ حالة انتظار الـ Auth Stream
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF006633)),
            ),
          );
        }

        final user = snapshot.data;

        // 2️⃣ المستخدم غير مسجل الدخول → Splash/Login
        if (user == null) {
          return const SplashScreen();
        }

        // 3️⃣ المستخدم مسجل الدخول → نعرض شاشة تحميل مؤقتة بينما نجلب بيانات Firestore
        return FutureBuilder<UserModel?>(
          future: authService.fetchUserModel(user.uid),
          builder: (context, userModelSnapshot) {
            if (userModelSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF006633)),
                ),
              );
            }

            final userModel = userModelSnapshot.data;

            // 4️⃣ إذا Firestore ما رجعش بيانات → نعرض الواجهة مع رسالة أو نسمح للمستخدم بالدخول بشكل محدود
            // ❌ هنا ما نعملوش signOut مباشرة → تجنب تعارض مع StreamBuilder
            if (userModel == null) {
              return const LimitedMapView(); // أو شاشة رسالة "بياناتك غير مكتملة"
            }

            // 5️⃣ التوجيه حسب الدور
            if (userModel.role == 'personnel') {
              return const PersonnelDashboard();
            } else {
              return const LimitedMapView();
            }
          },
        );
      },
    );
  }
}
