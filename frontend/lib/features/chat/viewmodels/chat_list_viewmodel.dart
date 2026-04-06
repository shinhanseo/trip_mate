import 'package:flutter/foundation.dart';
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
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      chatRoomList = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
