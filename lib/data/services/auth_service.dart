import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // 💡 تم إضافة هذا للاستخدام مع ChangeNotifier
import '../models/user_model.dart'; 

// 💡 يجب أن نستخدم with ChangeNotifier حتى يتمكن Provider من الاستماع للتغييرات
class AuthService with ChangeNotifier { 
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Yeni kullanıcı kaydı (Sign Up)
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String nationalId,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String role,
    String? institutionName,
  }) async {
    try {
      // Firebase Auth'ta hesap oluşturma
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı veri modelini oluşturma
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        nationalId: nationalId,
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        role: role,
        institutionName: institutionName,
      );

      // Ek kullanıcı verilerini Firestore'da saklama
      await _db.collection('users').doc(newUser.uid).set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Hatası: ${e.message}"); // 💡 تم تغيير print إلى debugPrint
      return null;
    } catch (e) {
      debugPrint("Genel Kayıt Hatası: $e"); // 💡 تم تغيير print إلى debugPrint
      return null;
    }
  }

  // 2. Giriş yapma (Sign In) - هذه هي الدالة التي تستخدمها شاشة الدخول (LoginScreen).
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Hatası: ${e.message}"); // 💡 تم تغيير print إلى debugPrint
      // 💡 مهم: يجب إلقاء الخطأ (rethrow) لكي تتمكن شاشة الدخول من التقاطه وعرضه للمستخدم.
      rethrow; 
    }
  }

  // 3. Firestore'dan kullanıcının tüm verilerini okuma (Rol dahil)
  // 💡 تم توحيد الاسم إلى fetchUserModel ليتطابق مع ما يتوقعه AuthWrapper.
  Future<UserModel?> fetchUserModel(String uid) async { 
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint("Kullanıcı verisi çekme hatası: $e"); // 💡 تم تغيير print إلى debugPrint
      return null;
    }
  }

  // 4. Kullanıcı durumunu takip etme (giriş yapmış mı kontrolü) - AuthWrapper يستخدم هذا Stream
  Stream<User?> get userChanges => _auth.authStateChanges();

  // 5. Çıkış yapma (Sign Out)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
