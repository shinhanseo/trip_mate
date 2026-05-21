import 'package:flutter/foundation.dart';

class AppErrorMessages {
  static const generic = '일시적인 오류가 발생했어요.\n잠시 후 다시 시도해주세요.';
  static const auth = '로그인 처리 중 문제가 발생했어요.\n잠시 후 다시 시도해주세요.';
  static const loginRequired = '로그인이 필요합니다.';
  static const meetingList = '일시적인 오류로 동행을 불러오지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const meetingDetail = '동행 정보를 불러오지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const meetingCreate = '동행이 생성되지 않았습니다.\n다시 한번 확인해주세요.';
  static const meetingUpdate = '동행이 수정되지 않았습니다.\n다시 한번 확인해주세요.';
  static const meetingDelete = '동행을 삭제하지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const myPage = '내 정보를 불러오지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const profile = '프로필 정보를 불러오지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const profileEdit = '프로필을 수정하지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const profileImageUpload = '프로필 이미지를 업로드하지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const accountDelete = '회원 탈퇴를 처리하지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const notifications = '알림을 불러오지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const notificationAction = '알림을 처리하지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const chatList = '채팅방 목록을 불러오지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const chatDetail = '채팅방을 불러오지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const chatConnection = '채팅방 연결 중 문제가 발생했어요.\n잠시 후 다시 시도해주세요.';
  static const placeSearch = '장소를 검색하지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const report = '신고를 접수하지 못했어요.\n잠시 후 다시 시도해주세요.';
  static const splash = '앱을 준비하는 중 문제가 발생했어요.\n다시 로그인해주세요.';
  static const bootstrap = '앱을 시작하지 못했어요.\n잠시 후 다시 실행해주세요.';
}

void logAppError(String context, Object error, [StackTrace? stackTrace]) {
  if (!kDebugMode) return;

  debugPrint('$context: $error');
  if (stackTrace != null) {
    debugPrintStack(stackTrace: stackTrace);
  }
}
