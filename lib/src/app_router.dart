library app_router;

import 'package:flutter/widgets.dart';

import 'app_route_builder.dart';
import 'app_route_transition.dart';
import 'transitions/slide_left_transition.dart';

typedef AppRouteWidgetBuilder = Widget Function(Object);

typedef AppRouteBuilderReturner = AppRouteBuilder Function(
  Widget,
  RouteSettings,
);

class AppRouteSettings {
  const AppRouteSettings({
    this.name,
    this.route,
    this.transition,
    this.onSameTransition,
    this.arguments,
  });

  final String name;
  final AppRouteBuilderReturner route;
  final AppRouteTransitionBuilder transition;
  final AppRouteTransitionBuilder onSameTransition;
  final Object arguments;
}

class AppRoute {
  AppRoute({
    this.name,
    this.builder,
    this.route,
    this.transition,
    this.onSameTransition,
    this.children,
  })  : assert(name != null),
        assert(builder != null);

  final String name;
  final AppRouteWidgetBuilder builder;
  final AppRouteBuilderReturner route;
  final AppRouteTransitionBuilder transition;
  final AppRouteTransitionBuilder onSameTransition;
  final List<AppRoute> children;
}

class AppRouter {
  AppRouter({
    @required List<AppRoute> routes,
    AppRouteTransitionBuilder defaultRouteTransition,
  })  : assert(routes != null && routes.isNotEmpty),
        defaultRouteTransition =
            defaultRouteTransition ?? SlideLeftRouteTransition.builder {
    _parseAppRoutes(routes);
    assert(_routes["/"] != null);
  }

  final AppRouteTransitionBuilder defaultRouteTransition;
  final Map<String, AppRoute> _routes = {};

  void _parseAppRoutes(List<AppRoute> routes, [String prefix = ""]) {
    for (int i = 0; i < routes.length; i++) {
      final AppRoute route = routes[i];

      String name = route.name;
      String path;

      name = name.length > 0 && name[name.length - 1] == '/'
          ? name.substring(0, name.length - 1)
          : name;

      if (name == "") {
        assert(route.children == null);
        if (prefix == "") {
          name = "";
        } else {
          name = "index";
        }
      }
      path = prefix + "/" + name;

      assert(_routes[path] == null);
      _routes[path] = route;

      if (route.children != null) {
        _parseAppRoutes(route.children, path);
      }
    }
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    AppRouteSettings routeSettings;
    AppRoute route = _routes[settings.name];
    if (settings.arguments is AppRouteSettings) {
      routeSettings = settings.arguments as AppRouteSettings;
    }

    if (route == null) {
      if (_routes["/404"] != null) {
        route = _routes["/404"];
      } else if (_routes["/unknown_route"] != null) {
        route = _routes["/unknown_route"];
      } else {
        route = _routes["/"];
      }
    }

    final RouteSettings newSettings = routeSettings != null
        ? RouteSettings(
            name: settings.name,
            arguments: routeSettings.arguments,
          )
        : settings;

    final AppRouteBuilderReturner routeBuilder = routeSettings?.route ??
        route.route ??
        (enterScreen, settings) => AppRouteBuilder(
              child: enterScreen,
              settings: settings,
              transitionBuilder: routeSettings?.transition ??
                  route.transition ??
                  defaultRouteTransition,
              onSameTransitionBuilder:
                  routeSettings?.onSameTransition ?? route.onSameTransition,
            );

    return routeBuilder(
      route.builder(routeSettings?.arguments ?? settings.arguments),
      newSettings,
    );
  }
}
