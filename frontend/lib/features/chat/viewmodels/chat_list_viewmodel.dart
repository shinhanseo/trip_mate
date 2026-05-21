import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/app_error.dart';

import '../services/chat_api.dart';
import '../models/chat_list_model.dart';

class ChatListViewModel extends ChangeNotifier {
  final ChatApi chatApi;

  ChatListViewModel({required this.chatApi});

  List<ChatListModel>? chatRoomList;
  bool isLoading = false;
  String? errorMessage;
  bool hasLoaded = false;

  Future<void> getChatRoomList() async {
    if (isLoading) return;
    if (hasLoaded) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await chatApi.getChatRoomList();

      chatRoomList = result;
      hasLoaded = true;
    } catch (e, stackTrace) {
      logAppError('Failed to load chat room list', e, stackTrace);
      errorMessage = AppErrorMessages.chatList;
      chatRoomList = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshChatRoomList() async {
    hasLoaded = false;
    await getChatRoomList();
  }
}
