import 'package:flutter/foundation.dart';
import '../errors/error_mapper.dart';

class AsyncNotifier extends ChangeNotifier {
  bool busy = false;
  String? errorMessage;
  bool _disposed = false;
  bool get isDisposed => _disposed;
  Object? get operationIdentity => this;

  void notify() {
    if (!_disposed) notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notify();
  }

  void reportError(Object error) {
    errorMessage = userMessage(error);
    notify();
  }

  Future<bool> run(Future<void> Function() action) async {
    if (busy || _disposed) return false;
    final identity = operationIdentity;
    busy = true;
    errorMessage = null;
    notify();
    try {
      await action().timeout(const Duration(seconds: 15));
      return !_disposed && identity == operationIdentity;
    } catch (error) {
      if (!_disposed && identity == operationIdentity) {
        errorMessage = userMessage(error);
      }
      return false;
    } finally {
      if (!_disposed && identity == operationIdentity) {
        busy = false;
        notify();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
