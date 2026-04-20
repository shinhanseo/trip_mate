import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/meeting_shared/widgets/meeting_filter_chips.dart';
import 'package:provider/provider.dart';
import '../viewmodels/meeting_update_viewmodel.dart';
import '../utils/meeting_form_formatters.dart';
import '../models/place_search_model.dart';
import '../models/meeting_update_model.dart';
import '../widgets/meeting_form_controls.dart';
import '../../home_more/models/meeting_model.dart';
import '../../../core/widgets/custom_message_dialog.dart';

class MeetingUpdatePage extends StatefulWidget {
  const MeetingUpdatePage({super.key});

  @override
  State<MeetingUpdatePage> createState() => _MeetingUpdatePageState();
}

class _MeetingUpdatePageState extends State<MeetingUpdatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isInitialized = false;

  late int meetingId;
  late MeetingDetailModel detail;

  String? _selectedPlaceName;
  String? _selectedPlaceAddress;
  double? _selectedPlaceLat;
  double? _selectedPlaceLng;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  int _memberCount = 2;

  List<String> selectedAgeGroups = ['any'];
  String? selectedGender = 'any';
  String? selectedCategory = 'cafe';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    meetingId = args['meetingId'] as int;
    detail = args['detail'] as MeetingDetailModel;

    final localDateTime = detail.scheduledAt.toLocal();

    _titleController.text = detail.title;
    _descriptionController.text = detail.description;

    _selectedPlaceName = detail.placeText;
    _selectedPlaceLat = detail.placeLat;
    _selectedPlaceLng = detail.placeLng;
    _selectedPlaceAddress = detail.placeAddress;

    _selectedDate = DateTime(
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
    );
    _selectedTime = TimeOfDay(
      hour: localDateTime.hour,
      minute: localDateTime.minute,
    );

    _memberCount = detail.maxMembers;
    selectedAgeGroups = List<String>.from(detail.ageGroups);
    selectedGender = detail.gender;
    selectedCategory = detail.category;

    _isInitialized = true;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingUpdateViewModel>().loadMe();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openPlaceSearchPage() async {
    final selected = await Navigator.pushNamed(context, '/meetingplacesearch');

    if (!mounted) return;

    if (selected != null && selected is PlaceSearchModel) {
      setState(() {
        _selectedPlaceName = selected.name;
        _selectedPlaceAddress = selected.address;
        _selectedPlaceLat = selected.lat;
        _selectedPlaceLng = selected.lng;
      });
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  DateTime? _getScheduledAt() {
    if (_selectedDate == null || _selectedTime == null) return null;

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  Future<void> _submitMeeting() async {
    final vm = context.read<MeetingUpdateViewModel>();
    final scheduledAt = _getScheduledAt();

    if (_titleController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const CustomMessageDialog(
          title: '제목을 입력해주세요.',
          message: '제목이 입력되지 않았습니다.\n다시 한번 확인해주세요.',
        ),
      );

      return;
    }

    if (_selectedPlaceName == null ||
        _selectedPlaceAddress == null ||
        _selectedPlaceLat == null ||
        _selectedPlaceLng == null) {
      showDialog(
        context: context,
        builder: (_) => const CustomMessageDialog(
          title: '동행 장소를 입력해주세요.',
          message: '동행 장소가 입력되지 않았습니다.\n다시 한번 확인해주세요.',
        ),
      );
      return;
    }

    if (scheduledAt == null) {
      showDialog(
        context: context,
        builder: (_) => const CustomMessageDialog(
          title: '동행 시간을 입력해주세요.',
          message: '동행 시간이 입력되지 않았습니다.\n다시 한번 확인해주세요.',
        ),
      );
      return;
    }

    if (selectedGender == null || selectedCategory == null) {
      return;
    }

    if (!selectedAgeGroups.contains('any') &&
        !selectedAgeGroups.contains(vm.ageRange)) {
      showDialog(
        context: context,
        builder: (_) => const CustomMessageDialog(
          title: '선택할 수 없어요.',
          message: '본인의 연령이 포함된 조건만 선택할 수 있어요.\n다시 한번 확인해주세요.',
        ),
      );

      return;
    }

    final meeting = MeetingUpdateModel(
      meetingId: meetingId,
      title: _titleController.text.trim(),
      placeText: _selectedPlaceName!,
      placeLat: _selectedPlaceLat!,
      placeLng: _selectedPlaceLng!,
      placeAddress: _selectedPlaceAddress!,
      scheduledAt: scheduledAt,
      maxMembers: _memberCount,
      gender: selectedGender!,
      ageGroups: selectedAgeGroups,
      category: selectedCategory!,
      description: _descriptionController.text.trim(),
    );

    try {
      await context.read<MeetingUpdateViewModel>().updateMeeting(meeting);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => CustomMessageDialog(
          title: '수정할 수 없어요.',
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeetingUpdateViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '동행 수정하기',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '제목',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: '제목을 입력하세요. (최대 20자)',
                        isDense: true,
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '제목을 입력해주세요 (최대 20자)';
                        }

                        if (value.trim().length > 20) {
                          return '제목은 20자를 넘길 수 없습니다.';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Text(
                    '장소',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: InkWell(
                      onTap: _openPlaceSearchPage,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.brandMint,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _selectedPlaceName ?? '장소를 선택하세요',
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedPlaceName == null
                                ? AppColors.mediumGray
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Text(
                    '시간',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(width: 16),

                  MeetingTimeButton(
                    icon: Icons.calendar_month_outlined,
                    text: meetingDateButtonLabel(_selectedDate),
                    onTap: () async {
                      await _pickDate();
                    },
                    color: _selectedDate == null
                        ? AppColors.disabledGray
                        : AppColors.black,
                  ),
                  const SizedBox(width: 14),
                  MeetingTimeButton(
                    icon: Icons.access_time,
                    text: meetingTimeButtonLabel(_selectedTime),
                    onTap: () async {
                      await _pickTime();
                    },
                    color: _selectedTime == null
                        ? AppColors.disabledGray
                        : AppColors.black,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '인원',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),
                      MemberCountSelector(
                        count: _memberCount,
                        onChanged: (value) {
                          setState(() {
                            _memberCount = value;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(width: 32),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        '성별',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      MeetingGenderChip(
                        selectedGender: selectedGender,
                        allowDeselection: false,
                        onChanged: (values) {
                          if (values != 'any' && vm.gender != values) {
                            showDialog(
                              context: context,
                              builder: (_) => const CustomMessageDialog(
                                title: '선택할 수 없어요.',
                                message:
                                    '본인의 성별이 포함된 조건만 선택할 수 있어요.\n다시 한번 확인해주세요.',
                              ),
                            );

                            return;
                          }
                          setState(() {
                            selectedGender = values;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                '연령',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              MeetingAgeGroupMultiChip(
                selectedAgeGroups: selectedAgeGroups,
                onChanged: (values) {
                  setState(() {
                    selectedAgeGroups = values;
                  });
                },
              ),

              const SizedBox(height: 12),

              const Text(
                '카테고리',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              MeetingCategoryChip(
                selectedCategory: selectedCategory,
                allowDeselection: false,
                onChanged: (values) {
                  setState(() {
                    selectedCategory = values;
                  });
                },
              ),

              const SizedBox(height: 12),

              const Text(
                '동행 소개',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                maxLines: 5,
                controller: _descriptionController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: '동행 설명을 작성해주세요',
                  isDense: true,
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요 (최대 20자)';
                  }

                  if (value.trim().length > 20) {
                    return '제목은 20자를 넘길 수 없습니다.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          height: 58,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.brandTeal, AppColors.brandLime],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  await _submitMeeting();
                },
                child: const Center(
                  child: Text(
                    '동행 수정하기',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
