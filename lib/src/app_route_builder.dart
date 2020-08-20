library app_router;

import 'package:flutter/widgets.dart';

import 'app_route_transition.dart';
import 'app_router.dart';

class AppRouteBuilder<T> extends ModalRoute<T> {
  static Duration defaultTransitionDuration = Duration(
    milliseconds: 200,
  );

  AppRouteBuilder({
    this.builder,
    this.child,
    @required AppRouteTransitionBuilder transitionBuilder,
    this.onSameTransitionBuilder,
    Duration transitionDuration,
    Duration reverseTransitionDuration,
    this.barrierColor,
    this.barrierLabel,
    this.barrierDismissible = true,
    this.barrierDisabled = false,
    this.opaque = true,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.enableUserGesture = true,
    this.noUserGestureForScopedWillPopCallback = false,
    RouteSettings settings,
  })  : assert(builder != null || child != null),
        assert(transitionBuilder != null),
        assert(opaque != null),
        assert(barrierDismissible != null),
        assert(fullscreenDialog != null),
        assert(noUserGestureForScopedWillPopCallback != null),
        transitionDuration = transitionDuration ?? defaultTransitionDuration,
        reverseTransitionDuration = reverseTransitionDuration ??
            transitionDuration ??
            defaultTransitionDuration,
        transitionBuilder = transitionBuilder,
        currentTransitionBuilder = transitionBuilder,
        super(
          settings: settings,
        );

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  final bool fullscreenDialog;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  @override
  final bool barrierDismissible;

  final bool barrierDisabled;

  @override
  final bool opaque;

  @override
  final bool maintainState;

  final bool enableUserGesture;

  final bool noUserGestureForScopedWillPopCallback;

  final Widget child;

  final WidgetBuilder builder;

  final AppRouteTransitionBuilder transitionBuilder;

  final AppRouteTransitionBuilder onSameTransitionBuilder;

  AppRouteTransitionBuilder currentTransitionBuilder;

  AppRouteBuilder previousRoute;

  bool _didPop = false;

  List<Route> get navigatorControllerRouteHistory =>
      AppNavigatorController.history;

  void _handlePreviousRoute() {
    if (previousRoute != null &&
        previousRoute.transitionBuilder.runtimeType ==
            transitionBuilder.runtimeType &&
        onSameTransitionBuilder != null) {
      currentTransitionBuilder = onSameTransitionBuilder;
    } else {
      currentTransitionBuilder = transitionBuilder;
    }
  }

  void transitionEndToListener(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _handlePreviousRoute();
      secondaryAnimation.removeStatusListener(transitionEndToListener);
    }
  }

  @override
  TickerFuture didPush() {
    navigatorControllerRouteHistory.add(this);
    return super.didPush();
  }

  @override
  bool didPop(result) {
    if (navigatorControllerRouteHistory.contains(this)) {
      navigatorControllerRouteHistory.removeAt(
        navigatorControllerRouteHistory.indexOf(this),
      );
    }
    _didPop = true;
    return super.didPop(result);
  }

  @override
  void didComplete(T result) {
    if (!_didPop && navigatorControllerRouteHistory.contains(this)) {
      navigatorControllerRouteHistory.removeAt(
        navigatorControllerRouteHistory.indexOf(this),
      );
    }
    super.didComplete(result);
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    if (nextRoute is AppRouteBuilder) {
      bool shouldUseOnSameTransitionBuilder =
          nextRoute.transitionBuilder.runtimeType ==
                  transitionBuilder.runtimeType &&
              nextRoute.onSameTransitionBuilder != null;

      currentTransitionBuilder = shouldUseOnSameTransitionBuilder
          ? nextRoute.onSameTransitionBuilder
          : nextRoute.transitionBuilder;

      secondaryAnimation.addStatusListener(transitionEndToListener);
      return true;
    }
    return super.canTransitionTo(nextRoute);
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    if (previousRoute is AppRouteBuilder) {
      this.previousRoute = previousRoute;
    }

    _handlePreviousRoute();

    return super.canTransitionFrom(previousRoute);
  }

  @override
  void changedInternalState() {
    if (!barrierDisabled) {
      super.changedInternalState();
    }
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    if (!barrierDisabled) {
      yield* super.createOverlayEntries();
    } else {
      yield OverlayEntry(builder: (_) => SizedBox());
    }
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result =
        builder != null ? builder(context) : Builder(builder: (_) => child);

    assert(() {
      if (result == null) {
        throw FlutterError(
            'The builder for route "${settings.name}" returned null.\n'
            'Route builders must never return null.');
      }
      return true;
    }());

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return currentTransitionBuilder(
      this,
      animation,
      secondaryAnimation,
      this.controller,
      child,
    );
  }

  bool get popGestureEnabled => !(this.isFirst ||
      !this.enableUserGesture ||
      this.willHandlePopInternally ||
      (this.noUserGestureForScopedWillPopCallback &&
          this.hasScopedWillPopCallback) ||
      this.fullscreenDialog ||
      this.animation.status != AnimationStatus.completed ||
      this.secondaryAnimation.status != AnimationStatus.dismissed ||
      this.navigator.userGestureInProgress);
}
