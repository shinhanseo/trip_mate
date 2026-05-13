import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/notification_api.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationApi notificationApi;

  NotificationViewModel({required this.notificationApi});

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await notificationApi.getNotifications();
      _unreadCount = _notifications
          .where((notification) => notification.readAt == null)
          .length;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await notificationApi.getUnreadCount();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadNotifications(forceRefresh: true);
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.readAt != null) return;

    try {
      await notificationApi.markAsRead(notification.id);

      final index = _notifications.indexWhere(
        (item) => item.id == notification.id,
      );

      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          readAt: DateTime.now(),
        );
      }

      if (_unreadCount > 0) {
        _unreadCount -= 1;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await notificationApi.markAllAsRead();

      final now = DateTime.now();

      _notifications = _notifications
          .map((notification) => notification.copyWith(readAt: now))
          .toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await notificationApi.deleteNotification(notificationId);

      final removed = _notifications.where(
        (notification) => notification.id == notificationId,
      );

      final wasUnread = removed.any(
        (notification) => notification.readAt == null,
      );

      _notifications = _notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      if (wasUnread && _unreadCount > 0) {
        _unreadCount -= 1;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      await notificationApi.deleteAllNotifications();

      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
