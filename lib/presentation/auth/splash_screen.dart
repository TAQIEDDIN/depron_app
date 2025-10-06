import 'package:flutter/material.dart';
import 'package:depron_app/presentation/auth/login_screen.dart'; // Doğrudan giriş ekranına geçeceğiz

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // 1. Arka plan
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF003300), Color(0xFF006633)], // Yeşil renk geçişi
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // 2. Ana içerik (ortada)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // İkon veya görsel
                  const Icon(
                    Icons.airplanemode_active,
                    size: 100.0,
                    color: Colors.lightGreenAccent,
                  ),
                  const SizedBox(height: 30.0),
    
                  // Başlık
                  const Text(
                    'DEPRON: Hızlı Yardım',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
    
                  // Açıklama
                  const Text(
                    'Yapay zekâ ve insansız hava araçları ile afet bölgelerinin anlık analizi.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // 3. Giriş düğmesi (altta)
          Positioned(
            bottom: 50,
            left: 32,
            right: 32,
            child: ElevatedButton(
              onPressed: () {
                // 💡 LoginScreen ekranına geçiş
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // AuthWrapper girişten sonra kontrol işlemini yapacak
                    builder: (context) => LoginScreen(), 
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen, // Canlı yeşil renk
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Başla ve Giriş Yap', 
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
