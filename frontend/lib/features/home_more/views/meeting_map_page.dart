import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MeetingMapPage extends StatelessWidget {
  final String title;
  final double lat;
  final double lng;

  const MeetingMapPage({
    super.key,
    required this.title,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    final position = NLatLng(lat, lng);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(target: position, zoom: 15),
          zoomGesturesEnable: true,
          scrollGesturesEnable: true,
        ),
        onMapReady: (controller) async {
          await controller.addOverlay(
            NMarker(id: 'meeting_place', position: position),
          );
        },
      ),
    );
  }
}
