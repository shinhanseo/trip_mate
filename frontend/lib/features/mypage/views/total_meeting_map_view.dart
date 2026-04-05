import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import '../viewmodels/total_meeting_map_viewmodel.dart';

class TotalMeetingMapView extends StatefulWidget {
  const TotalMeetingMapView({super.key});

  @override
  State<TotalMeetingMapView> createState() => _TotalMeetingMapViewState();
}

class _TotalMeetingMapViewState extends State<TotalMeetingMapView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TotalMeetingMapViewModel>().getTotalMeetingMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TotalMeetingMapViewModel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('동행 지도 확인하기')),
        body: Center(child: Text(vm.errorMessage!)),
      );
    }

    if (vm.totalMeetingMap.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('동행 지도 확인하기')),
        body: const Center(child: Text('표시할 동행 위치가 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        surfaceTintColor: const Color(0xffffffff),
        scrolledUnderElevation: 0,
        title: const Text('동행 지도 확인하기'),
      ),
      body: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(
              vm.totalMeetingMap.first.placeLat,
              vm.totalMeetingMap.first.placeLng,
            ),
            zoom: 11,
          ),
        ),
        onMapReady: (controller) async {
          final markers = vm.totalMeetingMap.map((meeting) {
            final marker = NMarker(
              id: meeting.id.toString(),
              position: NLatLng(meeting.placeLat, meeting.placeLng),
              caption: NOverlayCaption(text: meeting.title),
              size: const Size(20, 28),
            );

            marker.setOnTapListener((overlay) {
              if (!mounted) return;

              Navigator.pushNamed(
                context,
                '/meetingdetail',
                arguments: meeting.id,
              );
            });

            return marker;
          }).toSet();

          await controller.clearOverlays();
          await controller.addOverlayAll(markers);
        },
      ),
    );
  }
}
