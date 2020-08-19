library app_router;

import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'app_route_builder.dart';
import 'app_route_transition.dart';
import 'transitions/slide_left_transition.dart';

typedef AppRouteWidgetBuilder = Widget Function(Object);

typedef AppRouteBuilderReturner = AppRouteBuilder Function(
  Widget,
  RouteSettings,
);

class AppRouteBuilderSettings {
  AppRouteBuilderSettings({
    this.transition,
    this.onSameTransition,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.fullScreenDialog,
    this.opaque,
    this.transitionDesktop,
    this.onSameTransitionDesktop,
    this.transitionDurationDesktop,
    this.reverseTransitionDurationDesktop,
    this.fullScreenDialogDesktop,
    this.opaqueDesktop,
    this.transitionWeb,
    this.onSameTransitionWeb,
    this.transitionDurationWeb,
    this.reverseTransitionDurationWeb,
    this.fullScreenDialogWeb,
    this.opaqueWeb,
  });

  final AppRouteTransitionBuilder transition;
  final AppRouteTransitionBuilder onSameTransition;
  final AppRouteTransitionBuilder transitionDesktop;
  final AppRouteTransitionBuilder onSameTransitionDesktop;
  final AppRouteTransitionBuilder transitionWeb;
  final AppRouteTransitionBuilder onSameTransitionWeb;

  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final Duration transitionDurationDesktop;
  final Duration reverseTransitionDurationDesktop;
  final Duration transitionDurationWeb;
  final Duration reverseTransitionDurationWeb;

  final bool fullScreenDialog;
  final bool opaque;
  final bool fullScreenDialogDesktop;
  final bool opaqueDesktop;
  final bool fullScreenDialogWeb;
  final bool opaqueWeb;
}

class AppRouteSettings {
  const AppRouteSettings({
    this.name,
    this.route,
    this.routeSettings,
    this.arguments,
  });

  final String name;
  final AppRouteBuilderReturner route;
  final AppRouteBuilderSettings routeSettings;
  final Object arguments;
}

class AppRoute {
  const AppRoute({
    this.name,
    this.builder,
    this.route,
    this.children,
    this.routeSettings,
    this.isNode = false,
  }) : assert(isNode != null);

  final String name;
  final AppRouteWidgetBuilder builder;
  final AppRouteBuilderReturner route;
  final AppRouteBuilderSettings routeSettings;
  final List<AppRoute> children;
  final bool isNode;
}

class AppRouter {
  static const Duration defaultTransitionDuration = const Duration(
    milliseconds: 200,
  );

  static const Duration defaultReverseTransitionDuration =
      defaultTransitionDuration;

  static const Duration defaultTransitionDurationDesktop = const Duration(
    milliseconds: 350,
  );

  static const Duration defaultReverseTransitionDurationDesktop =
      defaultTransitionDurationDesktop;

  static const Duration defaultTransitionDurationWeb = const Duration(
    milliseconds: 350,
  );

  static const Duration defaultReverseTransitionDurationWeb =
      defaultTransitionDurationWeb;

  AppRouter({
    @required List<AppRoute> routes,
    AppRouteTransitionBuilder transition,
    AppRouteTransitionBuilder onSameTransition,
    Duration transitionDuration = defaultTransitionDuration,
    Duration reverseTransitionDuration = defaultReverseTransitionDuration,
    bool fullScreenDialog = false,
    bool opaque = true,
    AppRouteTransitionBuilder transitionDesktop,
    AppRouteTransitionBuilder onSameTransitionDesktop,
    Duration transitionDurationDesktop = defaultTransitionDurationDesktop,
    Duration reverseTransitionDurationDesktop =
        defaultTransitionDurationDesktop,
    bool fullScreenDialogDesktop = false,
    bool opaqueDesktop = true,
    AppRouteTransitionBuilder transitionWeb,
    AppRouteTransitionBuilder onSameTransitionWeb,
    Duration transitionDurationWeb = defaultTransitionDurationWeb,
    Duration reverseTransitionDurationWeb = defaultTransitionDurationWeb,
    bool fullScreenDialogWeb = false,
    bool opaqueWeb = true,
    this.strict = true,
  })  : assert(routes != null && routes.isNotEmpty),
        assert(strict != null),
        defaultRouteSettings = AppRouteBuilderSettings(
          transition: transition ?? SlideLeftRouteTransition.builder,
          onSameTransition: onSameTransition,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          fullScreenDialog: fullScreenDialog,
          opaque: opaque,
          transitionDesktop:
              transitionDesktop ?? SlideLeftRouteTransition.builder,
          onSameTransitionDesktop: onSameTransitionDesktop,
          transitionDurationDesktop: transitionDurationDesktop,
          reverseTransitionDurationDesktop: reverseTransitionDurationDesktop,
          fullScreenDialogDesktop: fullScreenDialogDesktop,
          opaqueDesktop: opaqueDesktop,
          transitionWeb: transitionWeb ?? SlideLeftRouteTransition.builder,
          onSameTransitionWeb: onSameTransitionWeb,
          transitionDurationWeb: transitionDurationWeb,
          reverseTransitionDurationWeb: reverseTransitionDurationWeb,
          fullScreenDialogWeb: fullScreenDialogWeb,
          opaqueWeb: opaqueWeb,
        ) {
    _parseAppRoutes(routes);
    assert(_routes["/"] != null);
  }

  final AppRouteBuilderSettings defaultRouteSettings;
  final Map<String, AppRoute> _routes = {};
  final bool strict;

  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  static bool get isWeb => kIsWeb;

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

      if (route.isNode) {
        assert(route.children == null, "$path should not have child routes");
      }

      if (!route.isNode) {
        assert(_routes[path] == null, "$path already defined (duplicate)");
        _routes[path] = route;
      }

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
        if (strict) {
          assert(
            false,
            "in 'scrict' mode routes: 'unknown_route' or '404' - should be defined",
          );
        }
        route = _routes["/"];
      }
    }

    final RouteSettings newSettings = routeSettings != null
        ? RouteSettings(
            name: settings.name,
            arguments: routeSettings.arguments,
          )
        : settings;

    AppRouteTransitionBuilder transitionBuilder;
    AppRouteTransitionBuilder onSameTransitionBuilder;
    Duration transitionDuration;
    Duration reverseTransitionDuration;
    bool fulScreenDialog;
    bool opaque;

    if (isDesktop) {
      transitionBuilder = routeSettings?.routeSettings?.transitionDesktop ??
          route.routeSettings?.transitionDesktop ??
          defaultRouteSettings.transitionDesktop;
      onSameTransitionBuilder =
          routeSettings?.routeSettings?.onSameTransitionDesktop ??
              route.routeSettings?.onSameTransitionDesktop ??
              defaultRouteSettings.onSameTransitionDesktop;
      transitionDuration =
          routeSettings?.routeSettings?.transitionDurationDesktop ??
              route.routeSettings?.transitionDurationDesktop ??
              defaultRouteSettings.transitionDurationDesktop;
      reverseTransitionDuration =
          routeSettings?.routeSettings?.reverseTransitionDurationDesktop ??
              route.routeSettings?.reverseTransitionDurationDesktop ??
              defaultRouteSettings.reverseTransitionDurationDesktop;
      fulScreenDialog = routeSettings?.routeSettings?.fullScreenDialogDesktop ??
          route.routeSettings?.fullScreenDialogDesktop ??
          defaultRouteSettings.fullScreenDialogDesktop;
      opaque = routeSettings?.routeSettings?.opaqueDesktop ??
          route.routeSettings?.opaqueDesktop ??
          defaultRouteSettings.opaqueDesktop;
    } else if (isWeb) {
      transitionBuilder = routeSettings?.routeSettings?.transitionWeb ??
          route.routeSettings?.transitionWeb ??
          defaultRouteSettings.transitionWeb;
      onSameTransitionBuilder =
          routeSettings?.routeSettings?.onSameTransitionWeb ??
              route.routeSettings?.onSameTransitionWeb ??
              defaultRouteSettings.onSameTransitionWeb;
      transitionDuration =
          routeSettings?.routeSettings?.transitionDurationWeb ??
              route.routeSettings?.transitionDurationWeb ??
              defaultRouteSettings.transitionDurationWeb;
      reverseTransitionDuration =
          routeSettings?.routeSettings?.reverseTransitionDurationWeb ??
              route.routeSettings?.reverseTransitionDurationWeb ??
              defaultRouteSettings.reverseTransitionDurationWeb;
      fulScreenDialog = routeSettings?.routeSettings?.fullScreenDialogWeb ??
          route.routeSettings?.fullScreenDialogWeb ??
          defaultRouteSettings.fullScreenDialogWeb;
      opaque = routeSettings?.routeSettings?.opaqueWeb ??
          route.routeSettings?.opaqueWeb ??
          defaultRouteSettings.opaqueWeb;
    } else {
      transitionBuilder = routeSettings?.routeSettings?.transition ??
          route.routeSettings?.transition ??
          defaultRouteSettings.transition;
      onSameTransitionBuilder =
          routeSettings?.routeSettings?.onSameTransition ??
              route.routeSettings?.onSameTransition ??
              defaultRouteSettings.onSameTransition;
      transitionDuration = routeSettings?.routeSettings?.transitionDuration ??
          route.routeSettings?.transitionDuration ??
          defaultRouteSettings.transitionDuration;
      reverseTransitionDuration =
          routeSettings?.routeSettings?.reverseTransitionDuration ??
              route.routeSettings?.reverseTransitionDuration ??
              defaultRouteSettings.reverseTransitionDuration;
      fulScreenDialog = routeSettings?.routeSettings?.fullScreenDialog ??
          route.routeSettings?.fullScreenDialog ??
          defaultRouteSettings.fullScreenDialog;
      opaque = routeSettings?.routeSettings?.opaque ??
          route.routeSettings?.opaque ??
          defaultRouteSettings.opaque;
    }

    final AppRouteBuilderReturner routeBuilder = routeSettings?.route ??
        route.route ??
        (enterScreen, settings) => AppRouteBuilder(
              child: enterScreen,
              settings: settings,
              transitionBuilder: transitionBuilder,
              onSameTransitionBuilder: onSameTransitionBuilder,
              transitionDuration: transitionDuration,
              reverseTransitionDuration: reverseTransitionDuration,
              fullscreenDialog: fulScreenDialog,
              opaque: opaque,
            );

    return routeBuilder(
      route.builder(routeSettings?.arguments ?? settings.arguments),
      newSettings,
    );
  }
}
