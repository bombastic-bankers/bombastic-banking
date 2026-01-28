import 'dart:async';
import 'package:flutter/material.dart';

/// Reason why a session ended.
enum SessionEndReason {
  /// User was inactive for more than the activity timeout period.
  inactivity,

  /// The session failed to refresh.
  refreshFailed,
}

/// Manages session keep-alive by automatically refreshing tokens based on user activity.
///
/// This service tracks user activity and schedules token refresh just before expiration.
/// If the user has been inactive when refresh is due, the session times out.
class SessionManager {
  final Future<DateTime?> Function() _getSessionExpiry;
  final Future<bool> Function() _onRefreshSession;
  final Future<void> Function(SessionEndReason reason) _onSessionEnd;
  final Duration _activityTimeout;
  final Duration _refreshBuffer;

  DateTime? _lastActivityTime;
  Timer? _refreshTimer;

  /// Creates a new SessionManager.
  ///
  /// [getSessionExpiry] is called to retrieve the expiration time of the current session.
  /// Should return null if no token exists.
  ///
  /// [onRefreshSession] is called to refresh the session.
  /// Should return true if the refresh was successful, false otherwise.
  ///
  /// [onSessionEnd] is called when the session ends.
  /// This callback should:
  /// - Clear the session token (preserve refresh token for biometric login)
  /// - Optionally show an appropriate message based on the reason
  /// - Navigate to the login screen
  ///
  /// [activityTimeout] is the maximum duration of inactivity before session timeout.
  /// Defaults to 1 minute.
  ///
  /// [refreshBuffer] is how long before token expiration to trigger refresh.
  /// Defaults to 10 seconds.
  SessionManager({
    required Future<DateTime?> Function() getSessionExpiry,
    required Future<bool> Function() onRefreshSession,
    required Future<void> Function(SessionEndReason reason) onSessionEnd,
    Duration activityTimeout = const Duration(minutes: 1),
    Duration refreshBuffer = const Duration(seconds: 10),
  }) : _getSessionExpiry = getSessionExpiry,
       _onRefreshSession = onRefreshSession,
       _onSessionEnd = onSessionEnd,
       _activityTimeout = activityTimeout,
       _refreshBuffer = refreshBuffer;

  /// Record user activity (navigation, tap, etc.)
  void recordActivity() {
    _lastActivityTime = DateTime.now();
  }

  /// Start monitoring and schedule the first token refresh.
  Future<void> startMonitoring() async {
    recordActivity();
    await _scheduleNextRefresh();
  }

  /// Stop monitoring and cancel any pending refresh timers.
  void stopMonitoring() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _lastActivityTime = null;
  }

  /// Schedule the next token refresh based on the current access token's expiration.
  Future<void> _scheduleNextRefresh() async {
    _refreshTimer?.cancel();

    final expirationTime = await _getSessionExpiry();
    if (expirationTime == null) return;

    final refreshTime = expirationTime.subtract(_refreshBuffer);
    final delay = refreshTime.difference(DateTime.now());

    if (delay.isNegative) {
      await _attemptRefresh();
    } else {
      _refreshTimer = Timer(delay, _attemptRefresh);
    }
  }

  /// Attempt to refresh the session, checking for recent activity first.
  Future<void> _attemptRefresh() async {
    if (!_isUserActive()) {
      return _endSession(SessionEndReason.inactivity);
    }

    try {
      final success = await _onRefreshSession();
      if (success) {
        await _scheduleNextRefresh();
      } else {
        await _endSession(SessionEndReason.refreshFailed);
      }
    } catch (e) {
      debugPrint('Error refreshing session: $e');
      await _endSession(SessionEndReason.refreshFailed);
    }
  }

  /// Check if user has been active within the timeout period.
  bool _isUserActive() {
    final lastActivity = _lastActivityTime;
    if (lastActivity == null) return false;

    final inactiveDuration = DateTime.now().difference(lastActivity);
    return inactiveDuration <= _activityTimeout;
  }

  /// End the session and clean up.
  Future<void> _endSession(SessionEndReason reason) async {
    stopMonitoring();
    await _onSessionEnd(reason);
  }
}
