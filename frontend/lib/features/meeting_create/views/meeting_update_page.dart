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

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _openPlaceSearchPage() async {
    _dismissKeyboard();

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

  InputDecoration _fieldDecoration(String hintText, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.gray400,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, size: 20, color: AppColors.gray500),
      filled: true,
      fillColor: AppColors.gray50,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.gray200, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.gray200, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.brandMint, width: 1.6),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required Widget child,
    double bottomGap = 22,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_sectionTitle(title), child],
      ),
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(
                  title: '제목',
                  child: TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    maxLength: 20,
                    onTapOutside: (_) => _dismissKeyboard(),
                    decoration: _fieldDecoration(
                      '어떤 동행을 모집하나요?',
                      prefixIcon: Icons.edit_outlined,
                    ).copyWith(counterText: ''),
                  ),
                ),

                _section(
                  title: '장소',
                  child: InkWell(
                    onTap: _openPlaceSearchPage,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.gray200,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 21,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedPlaceName ?? '장소를 선택하세요',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _selectedPlaceName == null
                                    ? AppColors.gray400
                                    : AppColors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 24,
                            color: AppColors.gray400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                _section(
                  title: '시간',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      MeetingTimeButton(
                        icon: Icons.calendar_month_outlined,
                        text: meetingDateButtonLabel(_selectedDate),
                        onTap: () async {
                          _dismissKeyboard();
                          await _pickDate();
                        },
                        color: _selectedDate == null
                            ? AppColors.disabledGray
                            : AppColors.black,
                      ),
                      MeetingTimeButton(
                        icon: Icons.access_time,
                        text: meetingTimeButtonLabel(_selectedTime),
                        onTap: () async {
                          _dismissKeyboard();
                          await _pickTime();
                        },
                        color: _selectedTime == null
                            ? AppColors.disabledGray
                            : AppColors.black,
                      ),
                    ],
                  ),
                ),

                _section(
                  title: '인원',
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: MemberCountSelector(
                      count: _memberCount,
                      onChanged: (value) {
                        setState(() {
                          _memberCount = value;
                        });
                      },
                    ),
                  ),
                ),

                const Divider(
                  color: AppColors.gray200,
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 22),

                _section(
                  title: '성별',
                  child: MeetingGenderChip(
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
                ),

                _section(
                  title: '연령',
                  child: MeetingAgeGroupMultiChip(
                    selectedAgeGroups: selectedAgeGroups,
                    onChanged: (values) {
                      setState(() {
                        selectedAgeGroups = values;
                      });
                    },
                  ),
                ),

                _section(
                  title: '카테고리',
                  child: MeetingCategoryChip(
                    selectedCategory: selectedCategory,
                    allowDeselection: false,
                    onChanged: (values) {
                      setState(() {
                        selectedCategory = values;
                      });
                    },
                  ),
                ),

                const Divider(
                  color: AppColors.gray200,
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 22),

                _section(
                  title: '동행 소개',
                  bottomGap: 0,
                  child: TextFormField(
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    minLines: 5,
                    maxLines: 5,
                    textAlignVertical: TextAlignVertical.top,
                    onFieldSubmitted: (_) => _dismissKeyboard(),
                    onTapOutside: (_) => _dismissKeyboard(),
                    scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 120,
                    ),
                    decoration: _fieldDecoration('함께할 여행자에게 알려주고 싶은 내용을 적어주세요'),
                  ),
                ),
              ],
            ),
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
                onTap: vm.isLoading
                    ? null
                    : () async {
                        _dismissKeyboard();
                        await _submitMeeting();
                      },
                child: Center(
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
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
