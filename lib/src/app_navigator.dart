library app_router;

import 'package:flutter/widgets.dart';

import 'app_router.dart';

class AppNavigatorController {
  AppNavigatorController(
    this.navigatorState,
  );

  final NavigatorState navigatorState;

  Future<T> pushNamed<T extends Object>(
    String routeName, {
    AppRouteSettings settings,
  }) =>
      navigatorState.pushNamed<T>(
        routeName,
        arguments: settings,
      );

  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
    String routeName, {
    TO result,
    AppRouteSettings settings,
  }) =>
      navigatorState.pushReplacementNamed<T, TO>(
        routeName,
        arguments: settings,
        result: result,
      );

  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
    String routeName, {
    TO result,
    AppRouteSettings settings,
  }) =>
      navigatorState.popAndPushNamed<T, TO>(
        routeName,
        arguments: settings,
        result: result,
      );

  Future<T> pushNamedAndRemoveUntil<T extends Object>(
    String newRouteName,
    RoutePredicate predicate, {
    AppRouteSettings settings,
  }) =>
      navigatorState.pushNamedAndRemoveUntil<T>(
        newRouteName,
        predicate,
        arguments: settings,
      );

  Future<T> push<T extends Object>(Route<T> route) =>
      navigatorState.push<T>(route);

  Future<T> pushReplacement<T extends Object, TO extends Object>(
    Route<T> newRoute, {
    TO result,
  }) =>
      navigatorState.pushReplacement<T, TO>(
        newRoute,
        result: result,
      );

  Future<T> pushAndRemoveUntil<T extends Object>(
    Route<T> newRoute,
    RoutePredicate predicate,
  ) =>
      navigatorState.pushAndRemoveUntil<T>(newRoute, predicate);

  void replace<T extends Object>({
    @required Route<dynamic> oldRoute,
    @required Route<T> newRoute,
  }) =>
      navigatorState.replace<T>(
        oldRoute: oldRoute,
        newRoute: newRoute,
      );

  void replaceRouteBelow<T extends Object>({
    @required Route<dynamic> anchorRoute,
    @required Route<T> newRoute,
  }) {
    return navigatorState.replaceRouteBelow<T>(
      anchorRoute: anchorRoute,
      newRoute: newRoute,
    );
  }

  bool canPop() => navigatorState.canPop();

  Future<bool> maybePop<T extends Object>([T result]) async =>
      navigatorState.maybePop<T>(result);

  void pop<T extends Object>([T result]) => navigatorState.pop<T>(result);

  void popUntil(RoutePredicate predicate) => navigatorState.popUntil(predicate);

  void removeRoute(Route<dynamic> route) => navigatorState.removeRoute(route);

  void removeRouteBelow(Route<dynamic> anchorRoute) =>
      navigatorState.removeRouteBelow(anchorRoute);
}

class AppNavigator {
  AppNavigator._();

  static AppNavigatorController of(BuildContext context) {
    NavigatorState navigatorState = Navigator.of(context);
    return AppNavigatorController(navigatorState);
  }
}
