import 'dart:async';
import 'package:flutter/foundation.dart';
import '../errors/app_exception.dart';
import 'async_notifier.dart';

/// Clears private state immediately on account changes. Old stream callbacks
/// and old write results cannot populate the new user's view.
abstract class UserScopedNotifier extends AsyncNotifier {
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Listenable? _session;
  String? Function()? _readUserId;
  String? userId;
  int _generation = 0;
  int _pendingStreams = 0;
  bool _attached = false;

  bool get loading => _pendingStreams > 0;
  @override
  Object get operationIdentity => _generation;

  void attach(Listenable session, String? Function() readUserId) {
    _session = session;
    _readUserId = readUserId;
    session.addListener(_syncUser);
    _syncUser();
  }

  void _syncUser() {
    final next = _readUserId?.call();
    if (_attached && next == userId) return;
    _attached = true;
    _generation++;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    _pendingStreams = 0;
    userId = next;
    busy = false;
    errorMessage = null;
    resetScope();
    if (next != null) bindUser(next);
    notify();
  }

  void watch<T>(Stream<T> stream, void Function(T value) accept) {
    final generation = _generation;
    var first = true;
    _pendingStreams++;
    _subscriptions.add(stream.listen((value) {
      if (isDisposed || generation != _generation) return;
      if (first) { first = false; _pendingStreams--; }
      accept(value);
      notify();
    }, onError: (Object error, StackTrace stack) {
      if (isDisposed || generation != _generation) return;
      if (first) { first = false; _pendingStreams--; }
      reportError(error);
    }));
  }

  String requireUser() {
    if (userId == null) throw const AppException('Sign in to use your personal kitchen.');
    if (loading) throw const AppException('Your kitchen is still loading. Please try again.');
    return userId!;
  }

  void retry() {
    _attached = false;
    _syncUser();
  }

  void resetScope();
  void bindUser(String uid);

  @override
  void dispose() {
    _session?.removeListener(_syncUser);
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
