import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/custom_message_dialog.dart';
import '../models/place_search_model.dart';
import '../viewmodels/place_search_viewmodel.dart';

class MeetingPlaceSearchPage extends StatefulWidget {
  const MeetingPlaceSearchPage({super.key});

  @override
  State<MeetingPlaceSearchPage> createState() => _MeetingPlaceSearchPageState();
}

class _MeetingPlaceSearchPageState extends State<MeetingPlaceSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    await context.read<PlaceSearchViewModel>().searchPlaces(
      _searchController.text,
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      await context.read<PlaceSearchViewModel>().searchPlaces(value);
    });
  }

  bool _isSelectable(PlaceSearchModel place) {
    return place.regionPrimary != null && place.regionPrimary!.isNotEmpty;
  }

  Future<void> _handlePlaceTap(PlaceSearchModel place) async {
    if (_isSelectable(place)) {
      Navigator.pop(context, place);
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => const CustomMessageDialog(
        title: '선택할 수 없어요.',
        message: '제주 동행 가능 지역이 아닌 장소입니다.\n다른 장소를 선택해주세요.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlaceSearchViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          '장소 검색',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              TextFormField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onFieldSubmitted: (_) async {
                  await _search();
                },
                decoration: InputDecoration(
                  hintText: '장소명을 검색하세요',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      await _search();
                    },
                    icon: const Icon(Icons.arrow_forward),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: AppColors.mint,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: AppColors.brandMint,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: AppColors.brandMint,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.errorMessage != null
                    ? Center(
                        child: Text(
                          vm.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : vm.places.isEmpty
                    ? const Center(
                        child: Text(
                          '검색 결과가 없습니다.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutralGray,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: vm.places.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final place = vm.places[index];

                          return _PlaceResultTile(
                            place: place,
                            onTap: () async {
                              await _handlePlaceTap(place);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceResultTile extends StatelessWidget {
  final PlaceSearchModel place;
  final VoidCallback onTap;

  const _PlaceResultTile({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isJejuRegion =
        place.regionPrimary != null && place.regionPrimary!.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.gray200, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                place.address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isJejuRegion ? AppColors.slate100 : AppColors.red50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isJejuRegion ? place.regionPrimary! : '제주 동행 지역 아님',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isJejuRegion
                        ? AppColors.slateGray
                        : AppColors.red700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
