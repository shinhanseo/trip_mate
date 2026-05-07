import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/meeting_shared/utils/meeting_filter_options.dart';
import 'package:frontend/features/meeting_shared/utils/meeting_filter_selection.dart';
import 'package:frontend/features/meeting_shared/widgets/meeting_filter_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';

import '../viewmodels/home_more_viewmodel.dart';
import '../widgets/meeting_card.dart';

class HomeMorePage extends StatefulWidget {
  const HomeMorePage({super.key});

  @override
  State<HomeMorePage> createState() => _HomeMorePageState();
}

class _HomeMorePageState extends State<HomeMorePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeMoreViewModel>().loadMeeting();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _applyCurrentFilters() async {
    final vm = context.read<HomeMoreViewModel>();

    await vm.applyFilters(
      category: vm.selectedCategory,
      gender: vm.selectedGender,
      ageGroup: vm.selectedAgeGroup,
      regionPrimary: vm.selectedRegionPrimary,
      query: _searchController.text.trim(),
    );
  }

  Future<void> _openFilterModal() async {
    final vm = context.read<HomeMoreViewModel>();

    final selection = await showMeetingFilterBottomSheet(
      context: context,
      initialSelection: MeetingFilterSelection(
        category: vm.selectedCategory,
        gender: vm.selectedGender,
        ageGroup: vm.selectedAgeGroup,
        regionPrimary: vm.selectedRegionPrimary,
      ),
    );

    if (!mounted || selection == null) return;

    await vm.applyFilters(
      category: selection.category,
      gender: selection.gender,
      ageGroup: selection.ageGroup,
      regionPrimary: selection.regionPrimary,
      query: _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeMoreViewModel>();
    final items = vm.meetingList?.items ?? [];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          '모행',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) async {
                  await _applyCurrentFilters();
                },
                decoration: InputDecoration(
                  hintText: '어떤 여행을 하고싶으세요?',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: _openFilterModal,
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

              InkWell(
                onTap: _openFilterModal,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          meetingFilterSummary(
                            category: vm.selectedCategory,
                            ageGroup: vm.selectedAgeGroup,
                            gender: vm.selectedGender,
                            regionPrimary: vm.selectedRegionPrimary,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.gray400,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<HomeMoreViewModel>().refresh(),
                  child: vm.isLoading && items.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : vm.errorMessage != null && items.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: Center(
                                child: Text(
                                  vm.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : items.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  hasMeetingFilters(
                                        category: vm.selectedCategory,
                                        ageGroup: vm.selectedAgeGroup,
                                        gender: vm.selectedGender,
                                        regionPrimary: vm.selectedRegionPrimary,
                                        query: _searchController.text,
                                      )
                                      ? '조건에 맞는 동행이 없습니다.'
                                      : '아직 생성된 동행이 없습니다.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neutralGray,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final meeting = items[index];
                            return MeetingCard(
                              meeting: meeting,
                              onTap: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  '/meetingdetail',
                                  arguments: meeting.id,
                                );

                                if (!context.mounted) return;

                                if (result == true) {
                                  await context
                                      .read<HomeMoreViewModel>()
                                      .loadMeeting(forceRefresh: true);
                                }
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.brandTeal, AppColors.brandLime],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/meetingcreate',
              );

              if (!context.mounted) return;

              if (result == true) {
                await context.read<HomeMoreViewModel>().refresh();
              }
            },
            child: const Center(
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
