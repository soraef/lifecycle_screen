import 'dart:async';

import 'package:flutter/material.dart';

enum LoadingType {
  white,
  transparent,
}

abstract class LifecycleScreenController extends ChangeNotifier {
  late final RouteObserver<PageRoute>? routeObserver;
  static RouteObserver<PageRoute> basePageRouteObserver =
      RouteObserver<PageRoute>();

  LifecycleScreenController({
    RouteObserver<PageRoute>? routeObserver,
  }) {
    if (routeObserver != null) {
      this.routeObserver = routeObserver;
    } else {
      this.routeObserver = basePageRouteObserver;
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isError => _errorMessage != null;

  LoadingType _loadingType = LoadingType.white;
  LoadingType get loadingType => _loadingType;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<StreamSubscription> _subscriptions = [];

  void onInit() {}

  void onDispose() {
    cancelSubscriptionAll();
  }

  void onDidPush() {}
  void onDidPushNext() {}
  void onDidPopNext() {}
  void onDidPop() {}

  void onInactive() {}
  void onPaused() {}
  void onResumed() {}
  void onDetached() {}
  void onHidden() {}

  void startLoading({
    LoadingType type = LoadingType.transparent,
  }) {
    _isLoading = true;
    _loadingType = type;
    notifyListeners();
  }

  void endLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void showError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> asyncRun(
    Future<void> Function() task, {
    LoadingType type = LoadingType.transparent,
  }) async {
    if (_isLoading) {
      return;
    }
    startLoading(type: type);
    try {
      await task();
    } catch (e) {
      showError(e.toString());
    } finally {
      endLoading();
    }
  }

  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  Future<void> cancelSubscription(StreamSubscription subscription) async {
    await subscription.cancel();
    _subscriptions.remove(subscription);
  }

  Future<void> cancelSubscriptionAll() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
  }
}
