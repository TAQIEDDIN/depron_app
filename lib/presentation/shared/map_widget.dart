// lib/presentation/shared/map_widget.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:depron_app/data/services/data_service.dart';
import 'package:depron_app/data/models/grid_analysis_model.dart';
import 'dart:ui' show Color; // Color sınıfını kullanmak için

class MapWidget extends StatelessWidget {
  final bool isPersonnel; // Görünümün personel mi yoksa kullanıcı için mi olduğunu belirler

  const MapWidget({Key? key, required this.isPersonnel}) : super(key: key);

  // Başlangıç konumu (örnek: Antakya bölgesi)
  static const LatLng initialCameraPosition = LatLng(36.208, 36.155); 

  // --------------------------------------------------------
  // Hex renk kodunu (ör: #FF0000) Color nesnesine dönüştür
  // --------------------------------------------------------
  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor; // Şeffaflık ekle
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // --------------------------------------------------------
  // Grid verilerine göre marker seti oluştur
  // --------------------------------------------------------
  Set<Marker> _buildMarkers(List<GridAnalysisModel> grids) {
    final Set<Marker> markers = {};

    for (var grid in grids) {
      // 💡 Personel / kullanıcı mantığı
      // Normal kullanıcı sadece insani yardım bölgelerini görür
      if (!isPersonnel && grid.status != 'Humanitarian Aid Area') {
        continue; // Kullanıcı için diğer bölgeleri atla
      }
      
      final color = _colorFromHex(grid.colorCode);

      markers.add(
        Marker(
          markerId: MarkerId(grid.gridId),
          position: LatLng(grid.latitude, grid.longitude),
          infoWindow: InfoWindow(
            title: grid.gridId,
            snippet: 'Durum: ${grid.status}, Kişi Sayısı: ${grid.humanCount}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            // Marker için basit renk mantığı
            color.value == Colors.red.value 
                ? BitmapDescriptor.hueRed 
                : BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }
    return markers;
  }

  // --------------------------------------------------------
  // Widget arayüzü
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return StreamBuilder<List<GridAnalysisModel>>(
      stream: dataService.gridAnalysisStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Harita verileri yüklenirken hata oluştu: ${snapshot.error}'));
        }

        final grids = snapshot.data ?? [];
        final markers = _buildMarkers(grids);

        // Veri yükleniyorsa progress indicator göster
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: initialCameraPosition,
            zoom: 13.0,
          ),
          markers: markers,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          // İsteğe bağlı: harita tipini değiştirebilirsin -> mapType: MapType.hybrid,
        );
      },
    );
  }
}
