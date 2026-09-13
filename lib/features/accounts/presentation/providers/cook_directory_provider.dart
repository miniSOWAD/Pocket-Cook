import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/account_repository.dart';
import '../../models/app_account.dart';

class CookDirectoryProvider extends ChangeNotifier {
  CookDirectoryProvider(AccountRepository repository) {
    _subscription = repository.watchCooks().listen((value) {
      cooks = value;
      loading = false;
      errorMessage = null;
      notifyListeners();
    }, onError: (Object error, StackTrace stack) {
      loading = false;
      errorMessage = userMessage(error);
      notifyListeners();
    });
  }

  late final StreamSubscription<List<AppAccount>> _subscription;
  List<AppAccount> cooks = const [];
  bool loading = true;
  String? errorMessage;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
