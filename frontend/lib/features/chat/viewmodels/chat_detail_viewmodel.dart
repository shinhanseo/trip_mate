import 'package:flutter/foundation.dart';

import '../models/chat_detail_model.dart';
import '../services/chat_api.dart';
import '../services/chat_socket_service.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final ChatApi chatApi;
  final ChatSocketService chatSocketService;

  ChatDetailViewModel({required this.chatApi, required this.chatSocketService});

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
    final accessToken = await chatApi.tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('로그인이 만료되었습니다.');
    }

    await chatSocketService.connect(
      accessToken: accessToken,
      meetingId: meetingId,
      onNewMessage: _handleNewMessage,
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
