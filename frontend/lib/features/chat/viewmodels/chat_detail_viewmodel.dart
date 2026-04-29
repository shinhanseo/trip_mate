import 'package:flutter/foundation.dart';

import '../models/chat_detail_model.dart';
import '../services/chat_api.dart';
import '../services/chat_socket_service.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final ChatApi chatApi;
  final ChatSocketService chatSocketService;
  final int currentUserId;

  ChatDetailViewModel({
    required this.chatApi,
    required this.chatSocketService,
    required this.currentUserId,
  });

  ChatDetailModel? chatDetail;
  bool isLoading = false;
  String? errorMessage;
  bool hasLoaded = false;

  Future<void> getChatDetail(int meetingId) async {
    if (isLoading) return;
    if (hasLoaded) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await chatApi.getChatDetail(meetingId);
      chatDetail = result;

      await connectSocket(meetingId);

      final lastMessage = chatDetail?.messages.isNotEmpty == true
          ? chatDetail!.messages.last
          : null;

      if (lastMessage != null && lastMessage.senderId != currentUserId) {
        chatSocketService.markAsRead(
          meetingId: meetingId,
          lastReadMessageId: lastMessage.id,
        );
      }

      hasLoaded = true;
    } catch (e) {
      hasLoaded = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      chatDetail = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> connectSocket(int meetingId) async {
    try {
      final accessToken = await chatApi.getValidAccessToken();
      await _connectSocketWithToken(meetingId, accessToken);
    } catch (error) {
      debugPrint('VM socket connect retry after token refresh error=$error');

      final refreshedAccessToken = await chatApi.getValidAccessToken(
        forceRefresh: true,
      );
      await _connectSocketWithToken(meetingId, refreshedAccessToken);
    }
  }

  Future<void> _connectSocketWithToken(
    int meetingId,
    String accessToken,
  ) async {
    if (accessToken.isEmpty) {
      throw Exception('로그인이 만료되었습니다.');
    }

    await chatSocketService.connect(
      accessToken: accessToken,
      meetingId: meetingId,
      currentUserId: currentUserId,
      onNewMessage: _handleNewMessage,
      onMessageRead: _handleMessageRead,
      onError: _handleSocketError,
    );
  }

  void sendMessage({required int meetingId, required String content}) {
    final trimmed = content.trim();

    if (trimmed.isEmpty) return;

    final didSend = chatSocketService.sendMessage(
      meetingId: meetingId,
      content: trimmed,
    );

    if (!didSend) {
      errorMessage = '채팅방 연결이 아직 완료되지 않았습니다.';
      notifyListeners();
    }
  }

  void _handleNewMessage(MessageModel message) {
    final current = chatDetail;

    if (current == null) return;

    chatDetail = ChatDetailModel(
      roomId: current.roomId,
      meeting: current.meeting,
      messages: [...current.messages, message],
    );

    debugPrint(
      'VM handleNewMessage id=${message.id} content=${message.content}',
    );

    notifyListeners();
  }

  void _handleMessageRead({
    required int readerId,
    required int previousLastReadMessageId,
    required int lastReadMessageId,
  }) {
    final current = chatDetail;

    if (current == null) return;

    final updatedMessages = current.messages.map((message) {
      final shouldDecrease =
          message.senderId != readerId &&
          message.id > previousLastReadMessageId &&
          message.id <= lastReadMessageId;

      if (!shouldDecrease) {
        return message;
      }

      return MessageModel(
        id: message.id,
        roomId: message.roomId,
        type: message.type,
        senderId: message.senderId,
        senderNickname: message.senderNickname,
        senderProfileImageUrl: message.senderProfileImageUrl,
        content: message.content,
        createdAt: message.createdAt,
        updatedAt: message.updatedAt,
        unreadCount: message.unreadCount > 0 ? message.unreadCount - 1 : 0,
      );
    }).toList();

    chatDetail = ChatDetailModel(
      roomId: current.roomId,
      meeting: current.meeting,
      messages: updatedMessages,
    );

    notifyListeners();
  }

  void _handleSocketError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    chatSocketService.dispose();
    super.dispose();
  }
}
