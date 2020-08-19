library app_router;

import 'dart:math';

import 'package:flutter/widgets.dart';

import '../app_route_transition.dart';

class FadeInRouteTransition extends StatefulWidget
    implements AppRouteTransition {
  static Curve transitionCurve = Curves.easeInOut;

  static Tween<double> aboveScreenOpacityTween = Tween<double>(
    begin: 0.0,
    end: 1.0,
  );

  static Tween<double> belowScreenOpacityTween = Tween<double>(
    begin: 1.0,
    end: 0.5,
  );

  static Tween<double> belowScreenBackdropOpacityTween = Tween<double>(
    begin: 0.0,
    end: 0.25,
  );

  static Color backdropColor = Color(0xFF000000);

  static AppRouteTransitionBuilder builder = (
    route,
    primaryAnimation,
    secondaryAnimation,
    routeAnimationController,
    child,
  ) =>
      FadeInRouteTransition(
        primaryAnimation: primaryAnimation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );

  FadeInRouteTransition({
    @required this.primaryAnimation,
    @required this.secondaryAnimation,
    @required this.child,
  })  : assert(primaryAnimation != null),
        assert(secondaryAnimation != null),
        assert(child != null);

  final Animation<double> primaryAnimation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  _FadeInRouteTransitionState createState() => _FadeInRouteTransitionState();
}

class _FadeInRouteTransitionState extends State<FadeInRouteTransition>
    with SingleTickerProviderStateMixin {
  CurvedAnimation _curvedAnimation;
  CurvedAnimation _curvedSecondaryAnimation;

  @override
  void initState() {
    _curvedAnimation = CurvedAnimation(
      curve: FadeInRouteTransition.transitionCurve,
      reverseCurve: FadeInRouteTransition.transitionCurve.flipped,
      parent: widget.primaryAnimation,
    );

    _curvedSecondaryAnimation = CurvedAnimation(
      curve: FadeInRouteTransition.transitionCurve,
      reverseCurve: FadeInRouteTransition.transitionCurve.flipped,
      parent: widget.secondaryAnimation,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _curvedSecondaryAnimation
          .drive(FadeInRouteTransition.belowScreenOpacityTween)
          .value,
      child: Opacity(
        opacity: _curvedAnimation
            .drive(FadeInRouteTransition.aboveScreenOpacityTween)
            .value,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: widget.child,
            ),
            if (widget.secondaryAnimation.status != AnimationStatus.dismissed)
              FadeTransition(
                opacity: widget.secondaryAnimation.drive(
                  FadeInRouteTransition.belowScreenBackdropOpacityTween,
                ),
                child: Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  color: FadeInRouteTransition.backdropColor,
                  height: double.infinity,
                  width: double.infinity,
                ),
              )
          ],
        ),
      ),
    );
  }
}
