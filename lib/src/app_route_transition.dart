library app_router;

import 'package:flutter/widgets.dart';

import 'app_route_builder.dart';

typedef AppRouteTransitionBuilder = AppRouteTransition Function(
  AppRouteBuilder,
  Animation<double>,
  Animation<double>,
  AnimationController,
  Widget,
);

abstract class AppRouteTransition extends Widget {
  ///  static AppRouteTransitionBuilder builder = (
  ///    route,
  ///    primaryAnimation,
  ///    secondaryAnimation,
  ///    routeAnimationController,
  ///    child,
  ///  ) =>
  ///      AppRouteTransition(
  ///        primaryAnimation: primaryAnimation,
  ///        child: child,
  ///      );

  AppRouteTransition({
    this.primaryAnimation,
    this.child,
  });

  final Animation<double> primaryAnimation;
  final Widget child;
}
