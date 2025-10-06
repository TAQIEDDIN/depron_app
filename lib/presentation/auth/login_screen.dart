// login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:depron_app/data/services/auth_service.dart';
import 'package:depron_app/core/constants/app_colors.dart';
import 'package:depron_app/presentation/auth/registration_screen.dart'; // استيراد شاشة التسجيل

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // 💡 وظيفة تسجيل الدخول
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // 1. محاولة تسجيل الدخول في Firebase Auth
      final user = await authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
      
      if (user != null) {
        // 2. إذا نجح الدخول، حاول جلب بيانات المستخدم من Firestore
        final userModel = await authService.fetchUserModel(user.uid);
        
        if (userModel == null) {
          // 3. حالة الخطأ: تسجيل الدخول ناجح ولكن لا توجد بيانات في Firestore
          // هذا هو سبب المشكلة المتكررة!
          await authService.signOut(); // تسجيل الخروج لتنظيف الحالة
          setState(() {
            _errorMessage = 'Giriş Başarılı, Ancak Kullanıcı Verileri Eksik. Lütfen yeni bir hesap oluşturarak kaydı tamamlayın.'; 
          });
          return;
        }
      }
      
      // إذا كان كل شيء على ما يرام (user != null و userModel != null)، سيتولى AuthWrapper التوجيه.
      
    } catch (e) {
      // التعامل مع أخطاء المصادقة (كلمة مرور غير صحيحة، مستخدم غير موجود، إلخ)
      setState(() {
        // رسالة الخطأ الأكثر شيوعاً
        _errorMessage = 'Giriş Hatası: E-posta veya şifre yanlış.'; 
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // شعار (Logo Placeholder)
                Icon(
                  Icons.person_pin_circle_rounded,
                  size: 100,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 16),
                const Text(
                  'DEPRON',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 40),

                // حقل البريد الإلكتروني
                _buildTextFormField(
                  controller: _emailController,
                  labelText: 'E-posta Adresi',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.contains('@') ? null : 'Geçerli e-posta girin',
                ),
                const SizedBox(height: 20),

                // حقل كلمة المرور
                _buildTextFormField(
                  controller: _passwordController,
                  labelText: 'Şifre',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (v) => v!.length >= 6 ? null : 'Şifre en az 6 karakter olmalı',
                ),
                const SizedBox(height: 30),

                // رسالة الخطأ
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),

                // زر تسجيل الدخول (Giriş Yap)
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 3),
                        )
                      : const Text(
                          'Giriş Yap',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // زر الانتقال للتسجيل (Hesap Oluştur)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                    );
                  },
                  child: const Text(
                    'Yeni bir hesap oluştur',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💡 تصميم حقل النص
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      cursorColor: AppColors.primaryGreen,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.secondaryText),
        prefixIcon: Icon(icon, color: AppColors.primaryGreen),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent, width: 0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}
