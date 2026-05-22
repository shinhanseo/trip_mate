import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/app_error.dart';

import '../models/notification_model.dart';
import '../services/notification_api.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationApi notificationApi;

  NotificationViewModel({required this.notificationApi});

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isDisposed = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (_isDisposed || (_isLoading && !forceRefresh)) return;

    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      final notifications = await notificationApi.getNotifications();
      if (_isDisposed) return;

      _notifications = notifications;
      _unreadCount = _notifications
          .where((notification) => notification.readAt == null)
          .length;
    } catch (e, stackTrace) {
      logAppError('Failed to load notifications', e, stackTrace);
      _errorMessage = AppErrorMessages.notifications;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final unreadCount = await notificationApi.getUnreadCount();
      if (_isDisposed) return;

      _unreadCount = unreadCount;
      _safeNotify();
    } catch (e, stackTrace) {
      logAppError('Failed to load unread notification count', e, stackTrace);
      if (_isDisposed) return;

      _errorMessage = AppErrorMessages.notifications;
      _safeNotify();
    }
  }

  Future<void> refresh() async {
    await loadNotifications(forceRefresh: true);
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (_isDisposed || notification.readAt != null) return;

    try {
      await notificationApi.markAsRead(notification.id);
      if (_isDisposed) return;

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

      _safeNotify();
    } catch (e, stackTrace) {
      logAppError('Failed to mark notification as read', e, stackTrace);
      if (_isDisposed) return;

      _errorMessage = AppErrorMessages.notificationAction;
      _safeNotify();
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    if (_isDisposed) return;

    try {
      await notificationApi.markAllAsRead();
      if (_isDisposed) return;

      final now = DateTime.now();

      _notifications = _notifications
          .map((notification) => notification.copyWith(readAt: now))
          .toList();

      _unreadCount = 0;
      _safeNotify();
    } catch (e, stackTrace) {
      logAppError('Failed to mark all notifications as read', e, stackTrace);
      if (_isDisposed) return;

      _errorMessage = AppErrorMessages.notificationAction;
      _safeNotify();
      rethrow;
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    if (_isDisposed) return;

    try {
      await notificationApi.deleteNotification(notificationId);
      if (_isDisposed) return;

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

      _safeNotify();
    } catch (e, stackTrace) {
      logAppError('Failed to delete notification', e, stackTrace);
      if (_isDisposed) return;

      _errorMessage = AppErrorMessages.notificationAction;
      _safeNotify();
      rethrow;
    }
  }

  Future<void> deleteAllNotifications() async {
    if (_isDisposed) return;

    try {
      await notificationApi.deleteAllNotifications();
      if (_isDisposed) return;

      _notifications = [];
      _unreadCount = 0;
      _safeNotify();
    } catch (e, stackTrace) {
      logAppError('Failed to delete all notifications', e, stackTrace);
      if (_isDisposed) return;

      _errorMessage = AppErrorMessages.notificationAction;
      _safeNotify();
      rethrow;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
