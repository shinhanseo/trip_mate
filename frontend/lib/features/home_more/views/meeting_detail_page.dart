import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/meeting_detail_viewmodel.dart';
import '../../../core/widgets/custom_message_dialog.dart';
import '../../../core/widgets/confirm_dialog.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        surfaceTintColor: const Color(0xffffffff),
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Text(
                detail.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(width: 8),

            if (isHost)
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
                          fontWeight: FontWeight.w600,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.regionPrimary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff9CA3AF),
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 14,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 22,
                        color: Color(0xff6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        detail.placeText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xff8D8D8D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 22,
                        color: Color(0xff6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(detail.scheduledAt),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xff8D8D8D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MeetingTag(
                    text: '${detail.currentMembers}/${detail.maxMembers}명',
                    backgroundColor: const Color(0xffF1F5F9),
                    textColor: const Color(0xff64748B),
                  ),
                  _MeetingTag(
                    text: _genderLabel(detail.gender),
                    backgroundColor: const Color(0xffECFDF5),
                    textColor: const Color(0xff047857),
                  ),
                  _MeetingTag(
                    text: _ageGroupLabel(detail.ageGroups),
                    backgroundColor: const Color(0xffEEF2FF),
                    textColor: const Color(0xff4338CA),
                  ),
                  _MeetingTag(
                    text: _categoryLabel(detail.category),
                    backgroundColor: const Color(0xffFFF7ED),
                    textColor: const Color(0xffC2410C),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Divider(color: Color(0xffE5E7EB), thickness: 1, height: 1),

              const SizedBox(height: 22),

              const Text(
                '동행 소개',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                detail.description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  color: Color(0xff4B5563),
                ),
              ),

              const SizedBox(height: 22),

              const Divider(color: Color(0xffE5E7EB), thickness: 1, height: 1),

              const SizedBox(height: 22),

              const Text(
                '함께할 여행자',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              ...detail.members.map((member) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
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
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF35C7B5), Color(0xFFD7E76C)],
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
                        },
                      ),
                    );
                  } else {
                    await context.read<MeetingDetailViewModel>().joinMeeting(
                      detail.id,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                isHost
                    ? "동행 삭제하기"
                    : isJoined
                    ? '나가기'
                    : '참여하기',
                style: const TextStyle(
                  fontSize: 22,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: textColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
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
    final Color badgeColor = isHost
        ? const Color(0xff7ED3C6)
        : const Color(0xffD7DF6A);
    final String genderStr = gender == 'M' ? '남성' : '여성';
    final String ageStr = '${ageRange[0]}0대';

    if (isHost == false && userId == currentUserId) {
      badgeText = '본인';
    }

    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xffE5E7EB), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xffF3F4F6),
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl.isEmpty
                  ? const Icon(Icons.person, color: Color(0xff9CA3AF))
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nickname,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$ageStr / $genderStr',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
