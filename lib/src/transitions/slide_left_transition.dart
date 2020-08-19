library app_router;

import 'package:flutter/widgets.dart';

import '../app_route_transition.dart';
import '../app_route_builder.dart';

enum _SlideLeftRouteTransitionDragDirection {
  Left,
  Right,
}

class SlideLeftRouteTransition extends StatefulWidget
    implements AppRouteTransition {
  static Curve transitionCurve = Curves.easeInCubic;

  static double swipeForwardStrengthValue = 5.0;
  static double swipeBackwardStrengthValue = 0.1;

  static double draggableWidth = 30.0;

  static Tween<Offset> belowScreenOffsetTween = Tween<Offset>(
    begin: const Offset(0, 0),
    end: const Offset(-0.5, 0),
  );

  static Tween<Offset> aboveScreenOffsetTween = Tween<Offset>(
    begin: const Offset(1, 0),
    end: const Offset(0, 0),
  );

  static Tween<double> opacityTween = Tween<double>(
    begin: 0.0,
    end: 0.5,
  );

  static Color backdropColor = Color(0xFF000000);


  static AppRouteTransitionBuilder builder = (
    route,
    primaryAnimation,
    secondaryAnimation,
    routeAnimationController,
    child,
  ) =>
      SlideLeftRouteTransition(
        route: route,
        primaryAnimation: primaryAnimation,
        secondaryAnimation: secondaryAnimation,
        routeAnimationController: routeAnimationController,
        child: child,
      );

  SlideLeftRouteTransition({
    @required this.route,
    @required this.primaryAnimation,
    @required this.secondaryAnimation,
    @required this.routeAnimationController,
    @required this.child,
  })  : assert(route != null),
        assert(primaryAnimation != null),
        assert(secondaryAnimation != null),
        assert(routeAnimationController != null),
        assert(child != null);

  final AppRouteBuilder route;
  final Animation<double> primaryAnimation;
  final Animation<double> secondaryAnimation;
  final AnimationController routeAnimationController;
  final Widget child;

  @override
  _SlideLeftRouteTransitionState createState() =>
      _SlideLeftRouteTransitionState();
}

class _SlideLeftRouteTransitionState extends State<SlideLeftRouteTransition>
    with SingleTickerProviderStateMixin {

  GlobalKey _enterScreenKey = GlobalKey();
  AnimationController _gestureAnimationController;

  CurvedAnimation _curvedAnimation;
  CurvedAnimation _curvedSecondaryAnimation;

  bool _isDragging = false;
  bool _isDraggingAnimation = false;
  double _enterScreenWidth;
  double _currentDragOffset;
  double _currentDragPosition;
  _SlideLeftRouteTransitionDragDirection _dragDirection;

  @override
  void initState() {
    _gestureAnimationController = AnimationController(
      vsync: this,
      duration: widget.route.reverseTransitionDuration,
    );

    _curvedAnimation = CurvedAnimation(
      curve: SlideLeftRouteTransition.transitionCurve,
      reverseCurve: SlideLeftRouteTransition.transitionCurve.flipped,
      parent: widget.primaryAnimation,
    );

    _curvedSecondaryAnimation = CurvedAnimation(
      curve: SlideLeftRouteTransition.transitionCurve,
      reverseCurve: SlideLeftRouteTransition.transitionCurve.flipped,
      parent: widget.secondaryAnimation,
    );

    _gestureAnimationController.addStatusListener(_statusListen);

    super.initState();
  }

  @override
  void dispose() {
    _gestureAnimationController?.removeStatusListener(_statusListen);
    _gestureAnimationController?.dispose();
    super.dispose();
  }

  void _statusListen(status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _isDraggingAnimation = false;
    } else if (!_isDraggingAnimation) {
      _isDraggingAnimation = true;
    }
  }

  void _dragStart([DragStartDetails details]) {
    if (_enterScreenKey.currentContext != null &&
        widget.route.popGestureEnabled &&
        widget.route.navigator.canPop() &&
        !_isDragging) {
      final RenderBox _box =
          _enterScreenKey.currentContext.findRenderObject() as RenderBox;

      widget.route.navigator.didStartUserGesture();

      _enterScreenWidth = _box.size.width;
      _isDragging = true;
      _isDraggingAnimation = true;
      _currentDragOffset = 1.0;
      _currentDragPosition = _enterScreenWidth;
      _dragDirection = _SlideLeftRouteTransitionDragDirection.Right;
    }
  }

  void _dragUpdate(DragUpdateDetails details) {
    if (_enterScreenWidth != null && _isDragging) {
      setState(() {
        final double _dx = details.delta.dx;
        _currentDragPosition = _currentDragPosition - _dx;

        final double _dragOffset = _currentDragPosition / _enterScreenWidth;
        _currentDragOffset = _dragOffset <= 1.0 ? _dragOffset : 1.0;

        if (_dx >=
            (_currentDragOffset > 0.5
                ? SlideLeftRouteTransition.swipeForwardStrengthValue
                : SlideLeftRouteTransition.swipeBackwardStrengthValue)) {
          _dragDirection = _SlideLeftRouteTransitionDragDirection.Left;
        } else if (_dx <=
            -(_currentDragOffset <= 0.5
                ? SlideLeftRouteTransition.swipeForwardStrengthValue
                : SlideLeftRouteTransition.swipeBackwardStrengthValue)) {
          _dragDirection = _SlideLeftRouteTransitionDragDirection.Right;
        }

        _gestureAnimationController.value = _currentDragOffset;
        widget.routeAnimationController.value = _currentDragOffset;
      });
    }
  }

  void _dragEnd([DragEndDetails details]) {
    if (_isDragging) {
      setState(() {
        widget.route.navigator.didStopUserGesture();

        if (_dragDirection == _SlideLeftRouteTransitionDragDirection.Left) {
          widget.route.navigator.pop();
          _gestureAnimationController.reverse();
        } else {
          widget.routeAnimationController.forward();
          _gestureAnimationController.forward();
        }

        _isDragging = false;
        _enterScreenWidth = null;
        _currentDragOffset = null;
        _currentDragPosition = null;
        _dragDirection = null;
      });
    }
  }

  Animation get _transitionAnimation =>
      _isDraggingAnimation ? _gestureAnimationController : _curvedAnimation;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _curvedSecondaryAnimation.drive(SlideLeftRouteTransition.belowScreenOffsetTween),
      child: SlideTransition(
        key: _enterScreenKey,
        position: _transitionAnimation.drive(SlideLeftRouteTransition.aboveScreenOffsetTween),
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
            if (widget.route.enableUserGesture && !widget.route.isFirst)
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onHorizontalDragStart: _dragStart,
                  onHorizontalDragUpdate: _dragUpdate,
                  onHorizontalDragEnd: _dragEnd,
                  onHorizontalDragCancel: _dragEnd,
                  onPanDown: (_) {},
                  onPanStart: (_) {},
                  onPanUpdate: (_) {},
                  onPanEnd: (_) {},
                  onPanCancel: () {},
                  behavior: HitTestBehavior.opaque,
                  child: SafeArea(
                    right: false,
                    top: false,
                    bottom: false,
                    child: SizedBox(
                      height: double.infinity,
                      width: SlideLeftRouteTransition.draggableWidth,
                    ),
                  ),
                ),
              ),
            if (widget.secondaryAnimation.status != AnimationStatus.dismissed)
              FadeTransition(
                opacity: SlideLeftRouteTransition.opacityTween.animate(widget.secondaryAnimation),
                child: Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  color: SlideLeftRouteTransition.backdropColor,
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
