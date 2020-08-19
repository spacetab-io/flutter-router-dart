library app_router;

import 'package:flutter/widgets.dart';

import 'app_route_transition.dart';

class AppRouteBuilder<T> extends PageRoute<T> {
  static const _defaultTransitionDuration = const Duration(
    milliseconds: 250,
  );

  AppRouteBuilder({
    this.builder,
    this.child,
    @required AppRouteTransitionBuilder transitionBuilder,
    this.onSameTransitionBuilder,
    Duration transitionDuration = _defaultTransitionDuration,
    Duration reverseTransitionDuration,
    this.barrierColor,
    this.barrierLabel,
    this.opaque = true,
    this.barrierDismissible = true,
    this.maintainState = true,
    bool fullscreenDialog = false,
    this.enableUserGesture = true,
    this.noUserGestureForScopedWillPopCallback = false,
    RouteSettings settings,
  })  : assert(builder != null || child != null),
        assert(transitionBuilder != null),
        assert(transitionDuration != null),
        assert(opaque != null),
        assert(barrierDismissible != null),
        assert(fullscreenDialog != null),
        assert(noUserGestureForScopedWillPopCallback != null),
        transitionDuration = transitionDuration,
        reverseTransitionDuration =
            reverseTransitionDuration ?? transitionDuration,
        transitionBuilder = transitionBuilder,
        currentTransitionBuilder = transitionBuilder,
        super(
          settings: settings,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool opaque;

  @override
  final bool barrierDismissible;

  @override
  final bool maintainState;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  final bool enableUserGesture;

  final bool noUserGestureForScopedWillPopCallback;

  final Widget child;

  final WidgetBuilder builder;

  final AppRouteTransitionBuilder transitionBuilder;

  final AppRouteTransitionBuilder onSameTransitionBuilder;

  AppRouteTransitionBuilder currentTransitionBuilder;

  AppRouteBuilder previousRoute;

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

  void transitionEndToListener(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _handlePreviousRoute();
      secondaryAnimation.removeStatusListener(transitionEndToListener);
    }
  }

  @override
  void didChangePrevious(Route previousRoute) {
    if (previousRoute is AppRouteBuilder) {
      this.previousRoute = previousRoute;
    }

    if (secondaryAnimation.status == AnimationStatus.dismissed) {
      _handlePreviousRoute();
    }
    super.didChangePrevious(previousRoute);
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
