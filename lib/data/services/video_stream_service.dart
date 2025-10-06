import 'dart:async';
import 'dart:math';

import 'package:depron_app/data/models/grid_analysis_model.dart';
import 'package:flutter/material.dart';

// 💡 Bu sınıf, IP kamera bağlantısını yönetir, video akışını simüle eder
// ve gerçek zamanlı analiz verilerini (belirli sınıflara ayrılmış) DataService'e iletir.
class VideoStreamService extends ChangeNotifier {
  // ----------------------------------------------------
  // Kamera Bağlantı Durumu
  // ----------------------------------------------------
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // 💡 Gecikme süresi (Latency) simülasyonu. Düşük gecikme (Low-Latency) hedeflenir.
  Duration _latency = const Duration(milliseconds: 0);
  Duration get latency => _latency;

  Timer? _analysisTimer;
  final Duration _streamDuration = const Duration(milliseconds: 100); // 10 FPS simülasyonu

  // ----------------------------------------------------
  // Veri Akışını Başlatma ve Durdurma
  // ----------------------------------------------------

  // 💡 Video akışını başlatır ve sahte analiz verilerini düzenli olarak gönderir.
  void startStream(Function(List<GridAnalysisModel>) onData) {
    if (_isConnected) return;

    _isConnected = true;
    _latency = const Duration(milliseconds: 50); // Simülasyon: Düşük gecikme

    // 💡 Sınıf analizi verilerini düzenli aralıklarla simüle et
    _analysisTimer = Timer.periodic(_streamDuration, (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }
      // 💡 Yeni bir analiz paketi oluştur ve DataService'e (onData) gönder.
      // Bu, "belirlediğim sınıfları (insan, hasar, araç) gösterme" mantığını temsil eder.
      final simulatedGrids = _simulateAnalysisData();
      onData(simulatedGrids);

      // Gecikme süresini rastgele güncelle (gerçekçilik için)
      _updateLatency();
      notifyListeners();
    });

    notifyListeners();
  }

  // 💡 Video akışını durdurur ve bağlantıyı keser.
  void stopStream() {
    if (!_isConnected) return;
    
    _analysisTimer?.cancel();
    _isConnected = false;
    _latency = const Duration(milliseconds: 0);
    notifyListeners();
  }
  
  // ----------------------------------------------------
  // Yardımcı Fonksiyonlar
  // ----------------------------------------------------
  
  // 💡 Analiz verilerini simüle eder (YOLO/AI'dan gelen verilerin yerine geçer)
  List<GridAnalysisModel> _simulateAnalysisData() {
    final random = Random();
    final List<GridAnalysisModel> grids = [];

    // Sahte 10-20 rastgele analiz bölgesi oluştur
    for (int i = 0; i < 15; i++) {
      grids.add(GridAnalysisModel(
        // Rastgele 10 bölgenin koordinatlarını simüle et
        latitude: 36.20 + (random.nextDouble() * 0.1) - 0.05,
        longitude: 36.15 + (random.nextDouble() * 0.1) - 0.05,
        
        // Önemli: Belirlediğimiz sınıfların simülasyonu
        humanCount: random.nextInt(15), 
        damageLevel: random.nextInt(4), // 0:Yok, 1:Hafif, 2:Orta, 3:Ağır
        vehicleCount: random.nextInt(8),
        
        // Simülasyonun benzersiz bir kimliği (Gerçekte çerçeve (frame) kimliği olabilir)
        frameId: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
    }
    return grids;
  }

  // 💡 Gecikme süresini (Latency) gerçek zamanlı olarak simüle et
  void _updateLatency() {
    final random = Random();
    // Gecikmeyi 30ms ile 120ms arasında rastgele ayarla (düşük gecikme)
    int newMs = 30 + random.nextInt(90); 
    _latency = Duration(milliseconds: newMs);
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }
}
