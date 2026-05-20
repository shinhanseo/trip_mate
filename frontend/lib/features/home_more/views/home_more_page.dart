import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/meeting_shared/utils/meeting_filter_options.dart';
import 'package:frontend/features/meeting_shared/utils/meeting_filter_selection.dart';
import 'package:frontend/features/meeting_shared/widgets/meeting_filter_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';

import '../../notification/viewmodels/notification_viewmodel.dart';
import '../../notification/widgets/notification_icon_button.dart';
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
      context.read<NotificationViewModel>().loadUnreadCount();
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

  Future<void> _clearFiltersAndSearch() async {
    final vm = context.read<HomeMoreViewModel>();

    _searchController.clear();
    vm.clearFilters();
    await vm.loadMeeting(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeMoreViewModel>();
    final items = vm.meetingList?.items ?? [];
    final hasFilters = hasMeetingFilters(
      category: vm.selectedCategory,
      ageGroup: vm.selectedAgeGroup,
      gender: vm.selectedGender,
      regionPrimary: vm.selectedRegionPrimary,
      query: _searchController.text,
    );

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
        actions: const [NotificationIconButton(), SizedBox(width: 8)],
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
                              child: _MeetingStateView(
                                icon: Icons.error_outline_rounded,
                                title: '동행을 불러오지 못했어요',
                                message: vm.errorMessage!,
                                actionLabel: '다시 시도',
                                onAction: () {
                                  context.read<HomeMoreViewModel>().refresh();
                                },
                              ),
                            ),
                          ],
                        )
                      : items.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.46,
                              child: _MeetingStateView(
                                icon: hasFilters
                                    ? Icons.search_off_rounded
                                    : Icons.groups_outlined,
                                title: hasFilters
                                    ? '조건에 맞는 동행이 없어요'
                                    : '아직 열린 동행이 없어요',
                                message: hasFilters
                                    ? '조건을 초기화하면 모집 중인 동행을\n다시 한눈에 볼 수 있어요.'
                                    : '첫 동행을 만들어 제주 여행을\n함께 시작해보세요.',
                                actionLabel: hasFilters ? '조건 초기화' : '동행 모집하기',
                                onAction: hasFilters
                                    ? _clearFiltersAndSearch
                                    : () async {
                                        final result =
                                            await Navigator.pushNamed(
                                              context,
                                              '/meetingcreate',
                                            );

                                        if (!context.mounted) return;

                                        if (result == true) {
                                          await context
                                              .read<HomeMoreViewModel>()
                                              .refresh();
                                        }
                                      },
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

class _MeetingStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MeetingStateView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: AppColors.brandMint.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 34, color: AppColors.brandTeal),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.brandMint),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandTeal,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
