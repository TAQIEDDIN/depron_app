// lib/data/models/grid_analysis_model.dart

class GridAnalysisModel {
  final String gridId;         // معرف الشبكة (مثل A1, B2)
  final double latitude;       // خط العرض لمركز الشبكة
  final double longitude;      // خط الطول لمركز الشبكة
  final int humanCount;        // عدد الأفراد المكتشفين في الشبكة
  final String status;         // حالة المنطقة (مثل Humanitarian Aid Area, Normal)
  final String colorCode;      // رمز اللون السداسي للعرض على الخريطة (مثل #FF0000)

  GridAnalysisModel({
    required this.gridId,
    required this.latitude,
    required this.longitude,
    required this.humanCount,
    required this.status,
    required this.colorCode,
  });

  // 1. الدالة المستخدمة لتحويل البيانات من Realtime Database إلى نموذج Dart
  factory GridAnalysisModel.fromMap(String key, Map<dynamic, dynamic> map) {
    return GridAnalysisModel(
      gridId: key, // نستخدم الـ Key (مفتاح الـ JSON) كـ Grid ID
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      humanCount: map['humanCount'] as int,
      status: map['status'] as String,
      colorCode: map['colorCode'] as String,
    );
  }

  // 2. الدالة المستخدمة لتحويل نموذج Dart إلى Map لإرساله إلى Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'humanCount': humanCount,
      'status': status,
      'colorCode': colorCode,
    };
  }
}