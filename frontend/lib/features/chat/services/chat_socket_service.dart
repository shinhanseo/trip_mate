import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/chat_detail_model.dart';

class ChatSocketService {
  final String socketBaseUrl;

  io.Socket? _socket;
  bool _isJoined = false;

  ChatSocketService({required this.socketBaseUrl});

  bool get isReady => _socket?.connected == true && _isJoined;

  Future<void> connect({
    required String accessToken,
    required int meetingId,
    required int currentUserId,
    required void Function(MessageModel message) onNewMessage,
    required void Function({
      required int readerId,
      required int previousLastReadMessageId,
      required int lastReadMessageId,
    })
    onMessageRead,
    required void Function(String message) onError,
  }) async {
    final joinCompleter = Completer<void>();

    _socket?.disconnect();
    _socket?.dispose();
    _isJoined = false;

    _socket = io.io(
      socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': accessToken})
          .build(),
    );

    _socket!.onConnect((_) {
      _socket!.emit('join_room', {'meetingId': meetingId});
    });

    _socket!.on('joined_room', (_) {
      _isJoined = true;
      if (!joinCompleter.isCompleted) {
        joinCompleter.complete();
      }
    });

    _socket!.on('new_message', (data) {
      try {
        final message = _parseMessage(data);
        onNewMessage(message);

        if (message.senderId != null && message.senderId != currentUserId) {
          markAsRead(meetingId: meetingId, lastReadMessageId: message.id);
        }
      } catch (e) {
        onError('새 메시지 형식이 올바르지 않습니다.');
      }
    });

    _socket!.on('message_read', (data) {
      try {
        final map = Map<String, dynamic>.from(data as Map);

        onMessageRead(
          readerId: _toInt(map['readerId']),
          previousLastReadMessageId: _toInt(map['previousLastReadMessageId']),
          lastReadMessageId: _toInt(map['lastReadMessageId']),
        );
      } catch (e) {}
    });

    _socket!.on('socket_error', (data) {
      final message = _parseErrorMessage(data);
      if (!_isJoined && !joinCompleter.isCompleted) {
        joinCompleter.completeError(Exception(message));
      }
      debugPrint('SOCKET error message=$message');
      onError(message);
    });

    _socket!.onConnectError((data) {
      debugPrint('SOCKET connect_error data=$data');
      const message = '채팅 서버 연결에 실패했습니다.';
      if (!joinCompleter.isCompleted) {
        joinCompleter.completeError(Exception(message));
      }
      onError(message);
    });

    _socket!.onError((data) {
      onError('채팅 서버 오류가 발생했습니다.');
    });

    _socket!.onDisconnect((data) {});

    _socket!.connect();
    await joinCompleter.future;
  }

  bool sendMessage({required int meetingId, required String content}) {
    if (!isReady) {
      return false;
    }

    debugPrint(
      'SOCKET emit send_message meetingId=$meetingId content=$content isReady=$isReady',
    );

    _socket?.emit('send_message', {'meetingId': meetingId, 'content': content});
    return true;
  }

  bool markAsRead({required int meetingId, required int lastReadMessageId}) {
    if (!isReady) {
      return false;
    }

    debugPrint(
      'SOCKET emit read_messages meetingId=$meetingId lastReadMessageId=$lastReadMessageId',
    );

    _socket?.emit('read_messages', {
      'meetingId': meetingId,
      'lastReadMessageId': lastReadMessageId,
    });

    return true;
  }

  void dispose() {
    _isJoined = false;
    _socket?.off('joined_room');
    _socket?.off('new_message');
    _socket?.off('message_read');
    _socket?.off('socket_error');
    _socket?.off('connect_error');
    _socket?.off('error');
    _socket?.off('disconnect');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  MessageModel _parseMessage(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    return MessageModel.fromJson(map);
  }

  String _parseErrorMessage(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    return (map['message'] ?? 'socket error').toString();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.parse(value.toString());
  }
}
