// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nationalId; // TC Kimlik Numarası
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String role; // 'user' veya 'personnel'
  final String? institutionName; // Kurum Adı (personel için isteğe bağlı)

  UserModel({
    required this.uid,
    required this.email,
    required this.nationalId,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.institutionName,
  });

  // Firestore verilerini modele dönüştürmek için fonksiyon (Map'ten Factory method)
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      nationalId: data['nationalId'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      role: data['role'] ?? 'user', 
      institutionName: data['institutionName'],
    );
  }

  // Modeli Firestore verisine dönüştürmek için fonksiyon (Firestore için Map)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nationalId': nationalId,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'institutionName': institutionName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
