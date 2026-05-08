import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../viewmodels/meeting_detail_viewmodel.dart';
import '../../../core/widgets/custom_message_dialog.dart';
import '../../../core/widgets/confirm_dialog.dart';
import './meeting_map_page.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

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
                style: const TextStyle(
                  fontSize: 22,
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
                  color: AppColors.gray400,
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
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        detail.placeText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.neutralGray,
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
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(detail.scheduledAt),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.neutralGray,
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

              const SizedBox(height: 22),

              const Divider(color: AppColors.gray200, thickness: 1, height: 1),

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
                  color: AppColors.gray600,
                ),
              ),

              const SizedBox(height: 22),

              const Divider(color: AppColors.gray200, thickness: 1, height: 1),

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
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/userprofile',
                        arguments: member.userId,
                      );
                    },
                    child: Padding(
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
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              const Divider(color: AppColors.gray200, thickness: 1, height: 1),

              const SizedBox(height: 20),

              SizedBox(
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
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
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
                          child: const Text('지도 크게 보기'),
                        ),
                      ),
                    ],
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
                height: 58,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
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
                              },
                            ),
                          );
                        } else {
                          await context
                              .read<MeetingDetailViewModel>()
                              .joinMeeting(detail.id);

                          if (!mounted) return;

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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      isHost
                          ? "동행 삭제하기"
                          : isJoined
                          ? '동행 나가기'
                          : '동행 참여하기',
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

    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gray200, width: 1.2),
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
              backgroundColor: AppColors.gray100,
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl.isEmpty
                  ? const Icon(Icons.person, color: AppColors.gray400)
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
                    color: AppColors.gray500,
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
