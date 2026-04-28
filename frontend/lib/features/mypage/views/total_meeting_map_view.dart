import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import '../viewmodels/total_meeting_map_viewmodel.dart';

class TotalMeetingMapView extends StatefulWidget {
  const TotalMeetingMapView({super.key});

  @override
  State<TotalMeetingMapView> createState() => _TotalMeetingMapViewState();
}

class _TotalMeetingMapViewState extends State<TotalMeetingMapView> {
  NaverMapController? _mapController;
  NOverlayImage? _clusterIcon;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _createClusterIcon();
      context.read<TotalMeetingMapViewModel>().getTotalMeetingMap();
    });
  }

  Future<void> _createClusterIcon() async {
    if (_clusterIcon != null) return;

    final icon = await NOverlayImage.fromWidget(
      context: context,
      size: const Size(44, 44),
      widget: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.brandTeal,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowBlack,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _clusterIcon = icon);
  }

  Future<void> _zoomIntoCluster(NClusterMarker clusterMarker) async {
    final controller = _mapController;
    if (controller == null) return;

    final camera = await controller.getCameraPosition();
    final nextZoom = (camera.zoom + 2).clamp(12.0, 18.0);
    final update =
        NCameraUpdate.scrollAndZoomTo(
          target: clusterMarker.position,
          zoom: nextZoom,
        )..setAnimation(
          animation: NCameraAnimation.easing,
          duration: const Duration(milliseconds: 450),
        );

    await controller.updateCamera(update);
  }

  Future<void> _fitAllMeetings(NaverMapController controller) async {
    final meetings = context.read<TotalMeetingMapViewModel>().totalMeetingMap;
    if (meetings.length < 2) return;

    final bounds = NLatLngBounds.from(
      meetings.map((meeting) => NLatLng(meeting.placeLat, meeting.placeLng)),
    );

    if (bounds.southWest == bounds.northEast) return;

    final update =
        NCameraUpdate.fitBounds(bounds, padding: const EdgeInsets.all(48))
          ..setAnimation(
            animation: NCameraAnimation.easing,
            duration: const Duration(milliseconds: 500),
          );

    await controller.updateCamera(update);
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
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
        clusterOptions: NaverMapClusteringOptions(
          mergeStrategy: const NClusterMergeStrategy(
            maxMergeableScreenDistance: 120,
            willMergedScreenDistance: {
              NInclusiveRange(0, 10): 120,
              NInclusiveRange(11, 13): 96,
              NInclusiveRange(14, 15): 72,
              NInclusiveRange(16, 18): 44,
            },
          ),
          clusterMarkerBuilder: (info, clusterMarker) {
            final icon = _clusterIcon;
            if (icon != null) {
              clusterMarker.setIcon(icon);
            }

            clusterMarker
              ..setSize(const Size(44, 44))
              ..setIsFlat(true)
              ..setCaption(
                NOverlayCaption(
                  text: info.size.toString(),
                  textSize: 14,
                  color: AppColors.white,
                  haloColor: Colors.transparent,
                ),
              )
              ..setOnTapListener(_zoomIntoCluster);
          },
        ),
        onMapReady: (controller) async {
          _mapController = controller;
          await _createClusterIcon();

          final markers = vm.totalMeetingMap.map((meeting) {
            final marker = NClusterableMarker(
              id: meeting.id.toString(),
              position: NLatLng(meeting.placeLat, meeting.placeLng),
              caption: NOverlayCaption(
                text: meeting.title,
                textSize: 11,
                color: AppColors.dark,
                haloColor: AppColors.white,
                minZoom: 14,
                requestWidth: 96,
              ),
              size: const Size(20, 28),
              isHideCollidedCaptions: true,
              isHideCollidedMarkers: true,
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
          await _fitAllMeetings(controller);
        },
      ),
    );
  }
}
