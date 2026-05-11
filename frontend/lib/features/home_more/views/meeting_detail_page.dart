import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../viewmodels/meeting_detail_viewmodel.dart';
import '../../../core/widgets/custom_message_dialog.dart';
import '../../../core/widgets/confirm_dialog.dart';
import './meeting_map_page.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../report/models/report_model.dart';
import '../../report/viewmodel/report_viewmodel.dart';

class MeetingDetailPage extends StatefulWidget {
  final int meetingId;

  const MeetingDetailPage({super.key, required this.meetingId});

  @override
  State<MeetingDetailPage> createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingDetailViewModel>().loadMeetingDetail(
        widget.meetingId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeetingDetailViewModel>();
    final detail = vm.meetingDetail;

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.errorMessage != null) {
      return Scaffold(body: Center(child: Text(vm.errorMessage!)));
    }

    if (detail == null) {
      return const Scaffold(body: Center(child: Text('상세 정보가 없습니다.')));
    }

    final int? currentUserId = vm.currentUserId;
    final bool isJoined = currentUserId != null
        ? detail.members.any((member) => member.userId == currentUserId)
        : false;
    final bool isHost = currentUserId == vm.hostUserId ? true : false;
    final bool isEnded = detail.scheduledAt.toLocal().isBefore(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Text(
                detail.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(width: 8),

            if (isHost && !isEnded)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.pushNamed(
                      context,
                      '/meetingupdate',
                      arguments: {
                        'meetingId': widget.meetingId,
                        'detail': detail,
                      },
                    );

                    if (!context.mounted) return;

                    if (result == true) {
                      await context.read<MeetingDetailViewModel>().refresh(
                        widget.meetingId,
                      );
                    }

                    return;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Center(
                      child: Text(
                        '수정하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (!isHost && !isEnded)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (value) async {
                  if (value == 'report') {
                    await _showMeetingReportBottomSheet(context);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'report',
                    child: Center(
                      child: Text(
                        '신고하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.red700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MeetingSummaryCard(
                region: detail.regionPrimary,
                placeText: detail.placeText,
                scheduledAt: _formatDateTime(detail.scheduledAt),
                tags: [
                  _MeetingTag(
                    text: '${detail.currentMembers}/${detail.maxMembers}명',
                    backgroundColor: AppColors.slate100,
                    textColor: AppColors.slate500,
                  ),
                  _MeetingTag(
                    text: _genderLabel(detail.gender),
                    backgroundColor: AppColors.success50,
                    textColor: AppColors.success700,
                  ),
                  _MeetingTag(
                    text: _ageGroupLabel(detail.ageGroups),
                    backgroundColor: AppColors.indigo50,
                    textColor: AppColors.indigo700,
                  ),
                  _MeetingTag(
                    text: _categoryLabel(detail.category),
                    backgroundColor: AppColors.orange50,
                    textColor: AppColors.orange700,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _DetailSection(
                title: '동행 소개',
                child: Text(
                  detail.description.isEmpty
                      ? '소개글이 없습니다.'
                      : detail.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                    color: AppColors.gray600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _DetailSection(
                title: '함께할 여행자',
                trailing: '${detail.currentMembers}명',
                child: Column(
                  children: detail.members.map((member) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/userprofile',
                              arguments: member.userId,
                            );
                          },
                          child: _UserProfile(
                            nickname: member.nickname,
                            role: member.role,
                            gender: member.gender,
                            ageRange: member.ageRange,
                            profileImageUrl: member.profileImageUrl ?? '',
                            userId: member.userId,
                            currentUserId: detail.currentUserId,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              _DetailSection(
                title: '만나는 장소',
                child: SizedBox(
                  height: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        NaverMap(
                          options: NaverMapViewOptions(
                            initialCameraPosition: NCameraPosition(
                              target: NLatLng(detail.placeLat, detail.placeLng),
                              zoom: 15,
                            ),
                            zoomGesturesEnable: true,
                            scrollGesturesEnable: true,
                          ),
                          onMapReady: (controller) async {
                            await controller.addOverlay(
                              NMarker(
                                id: 'meeting_place',
                                position: NLatLng(
                                  detail.placeLat,
                                  detail.placeLng,
                                ),
                                caption: NOverlayCaption(
                                  text: detail.placeText,
                                  textSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MeetingMapPage(
                                    title: detail.title,
                                    placeText: detail.placeText,
                                    lat: detail.placeLat,
                                    lng: detail.placeLng,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.open_in_full, size: 16),
                            label: const Text(
                              '크게 보기',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isEnded
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.brandTeal, AppColors.brandLime],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (isHost) {
                          if (vm.currentMembers != 1) {
                            showDialog(
                              context: context,
                              builder: (_) => const CustomMessageDialog(
                                title: '삭제할 수 없어요.',
                                message:
                                    '1명 이상의 동행자가 모집된 경우 삭제할 수 없습니다.\n다시 한번 확인해주세요.',
                              ),
                            );
                            return;
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => ConfirmDialog(
                                title: '동행을 삭제하시겠어요?',
                                message: '삭제 시 복구는 불가능합니다.',
                                cancelText: '취소',
                                confirmText: '삭제하기',
                                onConfirm: () async {
                                  try {
                                    await context
                                        .read<MeetingDetailViewModel>()
                                        .deleteMeeting(detail.id);

                                    if (!context.mounted) return;
                                    Navigator.pop(context, true);
                                  } catch (e) {
                                    if (!context.mounted) return;

                                    showDialog(
                                      context: context,
                                      builder: (_) => CustomMessageDialog(
                                        title: '삭제할 수 없어요.',
                                        message: e.toString().replaceFirst(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                            return;
                          }
                        }

                        if (isJoined) {
                          showDialog(
                            context: context,
                            builder: (_) => ConfirmDialog(
                              title: '동행에서 나가시겠어요?',
                              message: '나가면 다시 참여해야 합니다.',
                              cancelText: '취소',
                              confirmText: '나가기',
                              onConfirm: () async {
                                await context
                                    .read<MeetingDetailViewModel>()
                                    .leaveMeeting(detail.id);

                                if (!context.mounted) return;

                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (route) => false,
                                );
                              },
                            ),
                          );
                        } else {
                          await context
                              .read<MeetingDetailViewModel>()
                              .joinMeeting(detail.id);

                          if (!context.mounted) return;

                          await Navigator.pushNamed(
                            context,
                            '/chatdetail',
                            arguments: widget.meetingId,
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;

                        showDialog(
                          context: context,
                          builder: (_) => const CustomMessageDialog(
                            title: '참여할 수 없어요',
                            message: '동행 모집 조건에 맞지 않습니다.\n다시 한번 확인해주세요.',
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isHost
                          ? "동행 삭제하기"
                          : isJoined
                          ? '동행 나가기'
                          : '동행 참여하기',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    return '${local.month}/${local.day} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  static String _genderLabel(String gender) {
    switch (gender) {
      case 'male':
        return '남성';
      case 'female':
        return '여성';
      default:
        return '성별 무관';
    }
  }

  static String _ageGroupLabel(List<String> ageGroups) {
    if (ageGroups.isEmpty || ageGroups.contains('any')) {
      return '연령 무관';
    }

    final mapped = ageGroups.map((age) {
      if (age.endsWith('s')) {
        return '${age.replaceAll('s', '')}대';
      }
      return age;
    }).toList();

    return mapped.join(' · ');
  }

  static String _categoryLabel(String category) {
    switch (category) {
      case 'food':
        return '🍜 식사';
      case 'cafe':
        return '☕ 카페';
      case 'drink':
        return '🍺 술';
      case 'activity':
        return '🏄 액티비티';
      case 'tour':
        return '🚗 관광';
      default:
        return category;
    }
  }

  Future<void> _showMeetingReportBottomSheet(BuildContext context) async {
    final reasons = ['스팸/광고', '욕설/비방', '부적절한 내용', '사기 의심', '개인정보 노출', '기타'];

    String? selectedReason;
    final detailController = TextEditingController();
    final reportViewModel = context.read<ReportViewModel>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: reportViewModel,
          child: StatefulBuilder(
            builder: (context, setState) {
              final isEtc = selectedReason == '기타';
              final reportVm = context.watch<ReportViewModel>();
              final canSubmit =
                  selectedReason != null &&
                  (!isEtc || detailController.text.trim().isNotEmpty) &&
                  !reportVm.isLoading;

              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 18,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.gray300,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        '동행 신고하기',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '검토가 필요한 이유를 선택해주세요.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ...reasons.map((reason) {
                        final selected = selectedReason == reason;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: reportVm.isLoading
                                ? null
                                : () {
                                    setState(() {
                                      selectedReason = reason;
                                    });
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.red50
                                    : AppColors.gray50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.red700
                                      : AppColors.gray200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    selected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    size: 21,
                                    color: selected
                                        ? AppColors.red700
                                        : AppColors.gray400,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      reason,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: selected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: selected
                                            ? AppColors.red700
                                            : AppColors.gray600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      if (isEtc) ...[
                        const SizedBox(height: 4),
                        TextField(
                          controller: detailController,
                          maxLines: 4,
                          maxLength: 200,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: '신고 내용을 입력해주세요.',
                            hintStyle: const TextStyle(
                              color: AppColors.gray400,
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: AppColors.gray50,
                            counterStyle: const TextStyle(
                              color: AppColors.gray400,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.gray200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.red700,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: canSubmit
                              ? () async {
                                  final success = await context
                                      .read<ReportViewModel>()
                                      .createReport(
                                        targetType: ReportTargetType.meeting,
                                        targetId: widget.meetingId,
                                        reason: selectedReason!,
                                        detail: detailController.text,
                                      );

                                  if (!context.mounted) return;

                                  Navigator.pop(sheetContext);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? '신고가 접수되었습니다.'
                                            : '신고 접수에 실패했습니다.',
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red700,
                            disabledBackgroundColor: AppColors.gray200,
                            foregroundColor: AppColors.white,
                            disabledForegroundColor: AppColors.gray500,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: reportVm.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Text(
                                  '신고 제출하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    detailController.dispose();
  }
}

class _MeetingSummaryCard extends StatelessWidget {
  final String region;
  final String placeText;
  final String scheduledAt;
  final List<Widget> tags;

  const _MeetingSummaryCard({
    required this.region,
    required this.placeText,
    required this.scheduledAt,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            region,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryInfoRow(icon: Icons.location_on_outlined, text: placeText),
          const SizedBox(height: 8),
          _SummaryInfoRow(icon: Icons.access_time, text: scheduledAt),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: tags),
        ],
      ),
    );
  }
}

class _SummaryInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.gray500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.gray600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MeetingTag extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _MeetingTag({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: textColor.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _UserProfile extends StatelessWidget {
  final String nickname;
  final String role;
  final String gender;
  final String ageRange;
  final String profileImageUrl;
  final int userId;
  final int currentUserId;

  const _UserProfile({
    required this.nickname,
    required this.role,
    required this.gender,
    required this.ageRange,
    required this.profileImageUrl,
    required this.userId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHost = role == 'host';
    String badgeText = isHost ? '방장' : '동행자';
    final Color badgeColor = isHost ? AppColors.mintSoft : AppColors.limeSoft;
    final String genderStr = gender == 'M'
        ? '남성'
        : gender == 'F'
        ? '여성'
        : '정보 없음';
    final String ageStr = ageRange.isNotEmpty ? '${ageRange[0]}0대' : '정보 없음';

    if (isHost == false && userId == currentUserId) {
      badgeText = '본인';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.gray100,
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : null,
            child: profileImageUrl.isEmpty
                ? const Icon(Icons.person, color: AppColors.gray400)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$ageStr / $genderStr',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: AppColors.gray400,
          ),
        ],
      ),
    );
  }
}
