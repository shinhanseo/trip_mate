import 'package:flutter/material.dart';
import '../viewmodels/my_meeting_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../home_more/viewmodels/home_more_viewmodel.dart';
import '../../home_more/widgets/age_group_chip.dart';
import '../../home_more/widgets/category_chip.dart';
import '../../home_more/widgets/gender_chip.dart';
import '../../home_more/widgets/region_chip.dart';
import '../../home_more/widgets/meeting_card.dart';

class MyMeetingListPage extends StatefulWidget {
  final MyMeetingType type;

  const MyMeetingListPage({super.key, required this.type});

  @override
  State<MyMeetingListPage> createState() => _MyMeetingListPageState();
}

class _MyMeetingListPageState extends State<MyMeetingListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyMeetingViewModel>().loadMeetings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _applyCurrentFilters() async {
    final vm = context.read<MyMeetingViewModel>();

    await vm.applyFilters(
      category: vm.selectedCategory,
      gender: vm.selectedGender,
      ageGroup: vm.selectedAgeGroup,
      regionPrimary: vm.selectedRegionPrimary,
      query: _searchController.text.trim(),
    );
  }

  Future<void> _openFilterModal() async {
    final vm = context.read<MyMeetingViewModel>();

    String? tempCategory = vm.selectedCategory;
    String? tempGender = vm.selectedGender;
    String? tempAgeGroup = vm.selectedAgeGroup;
    String? tempRegion = vm.selectedRegionPrimary;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xffffffff),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xffD1D5DB),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        '필터',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        '카테고리',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),

                      CategoryChip(
                        selectedCategory: tempCategory,
                        onChanged: (value) {
                          setModalState(() {
                            tempCategory = value;
                          });
                        },
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        '연령',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      AgeGroupChip(
                        selectedAgeGroup: tempAgeGroup,
                        onChanged: (value) {
                          setModalState(() {
                            tempAgeGroup = value;
                          });
                        },
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        '성별',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      GenderChip(
                        selectedGender: tempGender,
                        onChanged: (value) {
                          setModalState(() {
                            tempGender = value;
                          });
                        },
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        '지역',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      RegionChip(
                        selectedRegion: tempRegion,
                        onChanged: (value) {
                          setModalState(() {
                            tempRegion = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempCategory = null;
                                  tempGender = null;
                                  tempAgeGroup = null;
                                  tempRegion = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                side: const BorderSide(
                                  color: Color(0xffD1D5DB),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                '초기화',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(modalContext);

                                await vm.applyFilters(
                                  category: tempCategory,
                                  gender: tempGender,
                                  ageGroup: tempAgeGroup,
                                  regionPrimary: tempRegion,
                                  query: _searchController.text.trim(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                backgroundColor: const Color(0xFF7AD8C4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                '적용',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _categoryLabel(String value) {
    switch (value) {
      case 'cafe':
        return '☕ 카페';
      case 'food':
        return '🍜 식사';
      case 'activity':
        return '🏄 액티비티';
      case 'drink':
        return '🍺 술';
      case 'tour':
        return '🚗 관광';
      default:
        return value;
    }
  }

  String _ageGroupLabel(String value) {
    switch (value) {
      case 'any':
        return '연령 무관';
      case '20s':
        return '20대';
      case '30s':
        return '30대';
      case '40s':
        return '40대';
      case '50s':
        return '50대';
      default:
        return value;
    }
  }

  String _genderLabel(String value) {
    switch (value) {
      case 'any':
        return '성별 무관';
      case 'male':
        return '남성';
      case 'female':
        return '여성';
      default:
        return value;
    }
  }

  String _filterSummary(MyMeetingViewModel vm) {
    final List<String> values = [];

    if (vm.selectedCategory != null && vm.selectedCategory!.isNotEmpty) {
      values.add(_categoryLabel(vm.selectedCategory!));
    }

    if (vm.selectedAgeGroup != null && vm.selectedAgeGroup!.isNotEmpty) {
      values.add(_ageGroupLabel(vm.selectedAgeGroup!));
    }

    if (vm.selectedGender != null && vm.selectedGender!.isNotEmpty) {
      values.add(_genderLabel(vm.selectedGender!));
    }

    if (vm.selectedRegionPrimary != null &&
        vm.selectedRegionPrimary!.isNotEmpty) {
      values.add(vm.selectedRegionPrimary!);
    }

    if (values.isEmpty) {
      return '전체 필터';
    }

    return values.join(' · ');
  }

  String get _title {
    switch (widget.type) {
      case MyMeetingType.total:
        return '전체 참여한 동행';
      case MyMeetingType.host:
        return '내가 만든 동행';
      case MyMeetingType.ing:
        return '진행 중인 동행';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyMeetingViewModel>();
    final items = vm.meetingList?.items ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        surfaceTintColor: const Color(0xffffffff),
        scrolledUnderElevation: 0,
        title: Text(
          _title,
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
                  hintText: '어떤 여행을 하셨나요?',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: _openFilterModal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: Color(0xFF2DD4BF),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: Color(0xFF7AD8C4),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: Color(0xFF7AD8C4),
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
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffE5E7EB)),
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
                          _filterSummary(vm),
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
                        color: Color(0xff9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<MyMeetingViewModel>().refresh(),
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
                          children: const [
                            SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  '동행이 없습니다.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff8D8D8D),
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
                                      .read<MyMeetingViewModel>()
                                      .loadMeetings(forceRefresh: true);
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
    );
  }
}
