library app_router;

import 'dart:math';

import 'package:flutter/widgets.dart';

import '../app_route_transition.dart';

class SlideTopRouteTransition extends StatefulWidget
    implements AppRouteTransition {
  static AppRouteTransitionBuilder builder = (
    route,
    primaryAnimation,
    secondaryAnimation,
    routeAnimationController,
    child,
  ) =>
      SlideTopRouteTransition(
        primaryAnimation: primaryAnimation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );

  SlideTopRouteTransition({
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
  _SlideTopRouteTransitionState createState() =>
      _SlideTopRouteTransitionState();
}

class _SlideTopRouteTransitionState extends State<SlideTopRouteTransition>
    with SingleTickerProviderStateMixin {
  static const Curve _transitionCurve = Curves.easeInOut;

  static TweenSequence<double> _belowScreenRotateXTween = TweenSequence(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 0.15),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0.15),
        weight: 50.0,
      ),
    ],
  );

  static TweenSequence<Offset> _belowScreenOffsetTween = TweenSequence(
    <TweenSequenceItem<Offset>>[
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0.0, 0.1),
        ),
        weight: 30.0,
      ),
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: const Offset(0.0, -0.25),
        ),
        weight: 70.0,
      ),
    ],
  );

  static Tween<Offset> _aboveScreenOffsetTween = Tween<Offset>(
    begin: const Offset(0, 1),
    end: const Offset(0, 0),
  );

  static Tween<double> _opacityTween = Tween<double>(
    begin: 0.0,
    end: 0.25,
  );

  CurvedAnimation _curvedAnimation;
  CurvedAnimation _curvedSecondaryAnimation;

  @override
  void initState() {
    _curvedAnimation = CurvedAnimation(
      curve: _transitionCurve,
      reverseCurve: _transitionCurve.flipped,
      parent: widget.primaryAnimation,
    );

    _curvedSecondaryAnimation = CurvedAnimation(
      curve: _transitionCurve,
      reverseCurve: _transitionCurve.flipped,
      parent: widget.secondaryAnimation,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(
          _curvedSecondaryAnimation.drive(_belowScreenRotateXTween).value * pi,
        ),
      alignment: Alignment.topCenter,
      child: SlideTransition(
        position: _curvedSecondaryAnimation.drive(
          _belowScreenOffsetTween,
        ),
        child: SlideTransition(
          position: _curvedAnimation.drive(
            _aboveScreenOffsetTween,
          ),
          child: Stack(
            children: <Widget>[
              SizedBox.expand(
                child: Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF000000).withOpacity(0.1),
                        offset: new Offset(-1.5, 0.0),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
              if (widget.secondaryAnimation.status != AnimationStatus.dismissed)
                FadeTransition(
                  opacity: _opacityTween.animate(widget.secondaryAnimation),
                  child: Container(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    color: Color(0xFF000000),
                    height: double.infinity,
                    width: double.infinity,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
