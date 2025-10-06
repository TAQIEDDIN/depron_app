import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'data/services/auth_service.dart';
// 💡 استيراد شاشة الترحيب الجديدة
import 'package:depron_app/presentation/auth/splash_screen.dart'; 
import 'auth_wrapper.dart'; 
import 'firebase_options.dart'; 
import 'data/services/data_service.dart'; 

// ...
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DataService>(create: (_) => DataService()), 
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...
      home: const SplashScreen(), // ⬅️ هذا هو الصحيح
    );
  }
}