//auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1️⃣ تسجيل مستخدم جديد (Sign Up)
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
      // إنشاء المستخدم في Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // إنشاء نموذج المستخدم
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

      // حفظ بيانات إضافية في Firestore
      await _db.collection('users').doc(newUser.uid).set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Sign Up Error: $e");
      return null;
    }
  }

  // 2️⃣ تسجيل الدخول (Sign In)
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.message}");
      rethrow; // يسمح للواجهة الأمامية بعرض رسالة الخطأ
    }
  }

  // 3️⃣ جلب بيانات المستخدم من Firestore
  Future<UserModel?> fetchUserModel(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint("Fetch UserModel Error: $e");
      return null;
    }
  }

  // 4️⃣ Stream لمتابعة حالة تسجيل الدخول/الخروج
  Stream<User?> get userChanges => _auth.authStateChanges();

  // 5️⃣ تسجيل الخروج (Sign Out)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
