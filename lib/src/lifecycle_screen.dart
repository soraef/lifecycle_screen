import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lifecycle_screen_controller.dart';

abstract class LifecycleScreen<T extends LifecycleScreenController>
    extends StatefulWidget {
  const LifecycleScreen({super.key});

  T createController();

  Widget buildView(BuildContext context, T controller);

  void onNotifyListeners(BuildContext context, T controller) {}

  @override
  LifecycleScreenState<T> createState() => LifecycleScreenState<T>();

  Widget buildLoading(BuildContext context, T controller) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget buildError(BuildContext context, T controller) {
    final errorMessage = context.select<T, String?>(
      (value) => value.errorMessage,
    );
    return Center(child: Text(errorMessage ?? 'Error'));
  }
}

class LifecycleScreenState<T extends LifecycleScreenController>
    extends State<LifecycleScreen<T>> with RouteAware, WidgetsBindingObserver {
  late final T controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = widget.createController();
    controller.addListener(onNotifyListeners);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onInit();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.routeObserver?.subscribe(
      this,
      ModalRoute.of(context) as PageRoute,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.routeObserver?.unsubscribe(this);
    controller.removeListener(onNotifyListeners);
    controller.onDispose();
    super.dispose();
  }

  void onNotifyListeners() {
    widget.onNotifyListeners(context, controller);
  }

  @override
  void didPush() {
    controller.onDidPush();
  }

  @override
  void didPushNext() {
    controller.onDidPushNext();
  }

  @override
  void didPopNext() {
    controller.onDidPopNext();
  }

  @override
  void didPop() {
    controller.onDidPop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        controller.onInactive();
        break;
      case AppLifecycleState.paused:
        controller.onPaused();
        break;
      case AppLifecycleState.resumed:
        controller.onResumed();
        break;
      case AppLifecycleState.detached:
        controller.onDetached();
        break;
      case AppLifecycleState.hidden:
        controller.onHidden();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Builder(
        builder: (context) {
          Widget body = widget.buildView(context, controller);
          final isLoading = context.select<T, bool>(
            (value) => value.isLoading,
          );
          final loadingType = context.select<T, LoadingType>(
            (value) => value.loadingType,
          );
          final errorMessage = context.select<T, String?>(
            (value) => value.errorMessage,
          );

          if (isLoading) {
            body = Material(
              child: Stack(
                children: [
                  body,
                  if (loadingType == LoadingType.transparent)
                    const Opacity(
                      opacity: 0.5,
                      child: ModalBarrier(
                        dismissible: false,
                        color: Colors.white,
                      ),
                    ),
                  if (loadingType == LoadingType.white)
                    const ModalBarrier(
                      dismissible: false,
                      color: Colors.white,
                    ),
                  widget.buildLoading(context, controller),
                ],
              ),
            );
          } else if (errorMessage != null) {
            body = Scaffold(
              body: widget.buildError(context, controller),
            );
          }

          return body;
        },
      ),
    );
  }
}
