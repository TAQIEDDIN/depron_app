// lib/data/services/data_service.dart

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:depron_app/data/models/grid_analysis_model.dart';
import 'package:rxdart/rxdart.dart';

class DataService {
  // المرجع لقاعدة بيانات Firebase Realtime Database
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // مسار البيانات التي يرسلها فريق الذكاء الاصطناعي
  final String _gridAnalysisPath = 'grid_analyses';

  // ----------------------------------------------------
  // 1. Stream لجلب بيانات تحليل الشبكات (الـ Grids) بشكل فوري
  // ----------------------------------------------------
  
  // BehaviorSubject: يسمح للمشتركين الجدد بالحصول على آخر قيمة تم إرسالها
  final BehaviorSubject<List<GridAnalysisModel>> _gridAnalysisSubject = 
      BehaviorSubject<List<GridAnalysisModel>>.seeded([]);

  Stream<List<GridAnalysisModel>> get gridAnalysisStream => _gridAnalysisSubject.stream;

  // ----------------------------------------------------
  // 2. Stream لحالة الاتصال بقاعدة البيانات
  // ----------------------------------------------------

  // StreamController: لإرسال حالة الاتصال إلى الواجهة
  final StreamController<String> _connectionStatusController =
      StreamController<String>.broadcast();
  
  Stream<String> get connectionStatusStream => _connectionStatusController.stream;

  DataService() {
    _initializeStreams();
  }

  void _initializeStreams() {
    // البدء بالاستماع للتغييرات في قاعدة البيانات
    _listenToGridAnalysis();
    
    // البدء بالاستماع لحالة الاتصال بالإنترنت وخادم Firebase
    _listenToConnectionStatus();
  }

  // ----------------------------------------------------
  // أ. جلب وتحويل البيانات الفورية (الـ Grids)
  // ----------------------------------------------------

  void _listenToGridAnalysis() {
    _database.ref(_gridAnalysisPath).onValue.listen((event) {
      final data = event.snapshot.value;
      
      // التحقق الأساسي من النوع
      if (data == null || data is! Map) {
        _gridAnalysisSubject.add([]);
        return;
      }
      
      // ✅ التعديل لحل مشكلة (data as Map)
      final Map<dynamic, dynamic> dataMap = data as Map<dynamic, dynamic>;
      
      final List<GridAnalysisModel> grids = [];
      
      // المرور على جميع العناصر وتحويلها إلى نماذج GridAnalysisModel
      dataMap.forEach((key, value) {
        if (key is String && value is Map) {
          try {
            grids.add(GridAnalysisModel.fromMap(key, value));
          } catch (e) {
            print('Error parsing GridAnalysisModel for key $key: $e');
          }
        }
      });
      
      // إرسال القائمة المحدثة إلى جميع المشتركين (الخريطة والرسوم البيانية)
      _gridAnalysisSubject.add(grids);
      
    }, onError: (Object error) {
      print('Error listening to grid analysis: $error');
      _gridAnalysisSubject.add([]);
    });
  }

  // ----------------------------------------------------
  // ب. مراقبة حالة الاتصال
  // ----------------------------------------------------

  void _listenToConnectionStatus() {
    // Firebase ينشر حالة الاتصال تحت هذا المسار
    _database.ref('.info/connected').onValue.listen((event) {
      final isConnected = event.snapshot.value as bool? ?? false;
      final status = isConnected ? 'Connected (متصل)' : 'Disconnected (قطع الاتصال)';
      _connectionStatusController.add(status);
      print('Database Connection Status: $status');
    });
  }
  
  // ----------------------------------------------------
  // ج. وظيفة لتنظيف الـ Streams عند إغلاق الخدمة
  // ----------------------------------------------------
  
  void dispose() {
    _gridAnalysisSubject.close();
    _connectionStatusController.close();
  }
}