import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:depron_app/data/services/auth_service.dart';
import 'package:depron_app/core/constants/app_colors.dart'; 

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Kontrolcüler
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _institutionNameController = TextEditingController(); // Kurum adı

  // Durum Yönetimi
  String? _selectedRole = 'user'; // Varsayılan rol: "user" (Kullanıcı)
  bool _isLoading = false;
  String? _errorMessage;

  // 💡 Kayıt fonksiyonu
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Role, null olmamalı.
    if (_selectedRole == null) {
      setState(() {
        _errorMessage = "Lütfen bir rol seçin (Bireysel Kullanıcı veya Personel).";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Kayıt işlemini başlat
      final user = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nationalId: _nationalIdController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: _selectedRole!,
        institutionName: _selectedRole == 'personnel' ? _institutionNameController.text.trim() : null,
      );

      if (user != null) {
        // Kayıt başarılıysa kullanıcıya bilgi ver ve giriş sayfasına dön
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
        );
        Navigator.pop(context); // Geri dön (LoginScreen'e)
      } else {
        // AuthService'ten null döndüyse (hata içeride yakalandı)
         setState(() {
          _errorMessage = "Kayıt sırasında bir hata oluştu. E-posta zaten kayıtlı olabilir.";
        });
      }
    } catch (e) {
      // Firebase Auth'tan gelen hatalar (e.g., weak-password)
      setState(() {
        _errorMessage = "Kayıt hatası: Lütfen girdiğiniz bilgileri kontrol edin.";
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
      appBar: AppBar(
        title: const Text(
          'Yeni Hesap Oluştur',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightBackground, 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Bilgilerinizi girerek Depron ailesine katılın.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 30),

              // --------------------------
              // İSİM SOYİSİM
              // --------------------------
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _firstNameController,
                      labelText: 'Adınız',
                      icon: Icons.person,
                      validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _lastNameController,
                      labelText: 'Soyadınız',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --------------------------
              // E-POSTA VE ŞİFRE
              // --------------------------
              _buildTextFormField(
                controller: _emailController,
                labelText: 'E-posta',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.contains('@') ? null : 'Geçerli e-posta girin',
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _passwordController,
                labelText: 'Şifre (min 6 karakter)',
                icon: Icons.lock,
                obscureText: true,
                validator: (v) => v!.length >= 6 ? null : 'Şifre en az 6 karakter olmalı',
              ),
              const SizedBox(height: 20),

              // --------------------------
              // TC KİMLİK VE TELEFON
              // --------------------------
              _buildTextFormField(
                controller: _nationalIdController,
                labelText: 'TC Kimlik No',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                validator: (v) => v!.length == 11 ? null : '11 haneli TC girin',
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _phoneNumberController,
                labelText: 'Telefon Numarası',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length >= 10 ? null : 'Geçerli telefon no girin',
              ),
              const SizedBox(height: 30),

              // --------------------------
              // ROL SEÇİMİ (Dropdown)
              // --------------------------
              _buildRoleDropdown(),
              const SizedBox(height: 20),

              // --------------------------
              // KURUM ADI (Sadece Personel için)
              // --------------------------
              if (_selectedRole == 'personnel') 
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildTextFormField(
                    controller: _institutionNameController,
                    labelText: 'Kurum Adı (Örn: AFAD, Kızılay)',
                    icon: Icons.business,
                    validator: (v) => v!.isEmpty ? 'Personel iseniz kurum adı gerekli' : null,
                  ),
                ),

              // --------------------------
              // Hata Mesajı
              // --------------------------
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),

              // --------------------------
              // KAYIT BUTONU
              // --------------------------
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
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
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Hesabı Oluştur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 💡 Birleşik alan stilini oluşturan yardımcı widget
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
  
  // 💡 Rol seçimi için Dropdown
  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Kullanıcı Rolü',
        labelStyle: const TextStyle(color: AppColors.secondaryText),
        prefixIcon: const Icon(Icons.group, color: AppColors.primaryGreen),
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
      ),
      items: const [
        DropdownMenuItem(value: 'user', child: Text('Bireysel Kullanıcı')),
        DropdownMenuItem(value: 'personnel', child: Text('Personel / Kurtarma Ekibi')),
      ],
      onChanged: (String? newValue) {
        setState(() {
          _selectedRole = newValue;
          // Rol değiştiğinde, eğer user seçildiyse kurum adını temizle
          if (_selectedRole == 'user') {
            _institutionNameController.clear();
          }
        });
      },
      validator: (value) => value == null ? 'Lütfen rolünüzü seçin.' : null,
    );
  }
}
