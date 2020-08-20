import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_router_dart/index.dart';

void main() {
  runApp(MyApp());
}

class AppScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}

final List<AppRoute> routes = [
  AppRoute(
    name: "/",
    builder: (_) => PageOne(),
  ),
  AppRoute(
    name: "2",
    builder: (_) => PageTwo(),
  ),
  AppRoute(
      name: "3",
      builder: (_) => PageThree(),
      routeSettings: AppRouteBuilderSettings(
        transition: FadeInRouteTransition.builder,
      ),
      children: [
        AppRoute(
          name: "/",
          builder: (_) => PageTwo(),
        ),
        AppRoute(
          name: "2",
          builder: (_) => PageTwo(),
        ),
        AppRoute(name: "3", builder: (_) => PageTwo(), children: [
          AppRoute(
            name: "/",
            builder: (_) => PageTwo(),
          ),
          AppRoute(
            name: "2",
            builder: (_) => PageTwo(),
          ),
        ]),
      ]),
  AppRoute(
      name: "4",
      builder: (_) => PageFour(),
      routeSettings: AppRouteBuilderSettings(
        transition: SlideTopRouteTransition.builder,
      )),
  AppRoute(
      name: "5",
      builder: (_) => PageFive(),
      routeSettings: AppRouteBuilderSettings(
        transition: SlideTopRouteTransition.builder,
      )),
  AppRoute(
      name: "6",
      builder: (_) => PageSix(),
      routeSettings: AppRouteBuilderSettings(
        transition: SlideTopRouteTransition.builder,
        onSameTransition: SlideLeftRouteTransition.builder,
      )),
  AppRoute(
    name: "7",
    builder: (_) => PageSeven(),
  )
];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: const Color(0x00000000),
      ),
      child: WidgetsApp(
        title: 'Flutter Demo',
        color: Colors.red,
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: AppScrollBehavior(),
            child: child,
          );
        },
        onGenerateRoute: AppRouter(routes: routes).onGenerateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class Page extends StatelessWidget {
  Page(
    this.title,
    this.buttons, {
    this.bgColor,
  });

  final String title;
  final List<Widget> buttons;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    print(AppNavigatorController.history.map((e) => e.settings.name));

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgColor == null ? Colors.blue : bgColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: buttons,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page("Slide Left Page 1", [
      FlatButton(
        onPressed: () {
          AppNavigator.of(context).pushNamed("/2");
        },
        child: Text("Slide from left to Page 2"),
      ),
    ]);
  }
}

class PageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page("Slide Left Page 2", [
      FlatButton(
        onPressed: () {
          AppNavigator.of(context).pushNamed("/3");
        },
        child: Text("Fade in to Page 3"),
      ),
      FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("Slide left to Page 1"),
      ),
//      FlatButton(
//        onPressed: () {
//          ThemeResolver.of(context).nextTheme();
//        },
//        child: Text("Change theme"),
//      )
    ]);
  }
}

class PageThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      "Fade In Page 3",
      [
        FlatButton(
          onPressed: () {
            AppNavigator.of(context).pushReplacementNamed("/4");
          },
          child: Text("Slide from top to Page 4 top (replace this)"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Fade out to Page 2"),
        ),
      ],
      bgColor: Colors.lightGreen,
    );
  }
}

class PageFour extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      "Slide Top Page 4",
      [
        FlatButton(
          onPressed: () {
            AppNavigator.of(context).pushNamed("/5");
          },
          child: Text("Slide from top to Page 5"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Slide top to Page 3"),
        ),
      ],
      bgColor: Colors.yellow,
    );
  }
}

class PageFive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      "Slide Top Page 5",
      [
        FlatButton(
          onPressed: () {
            AppNavigator.of(context).pushNamed("/6");
          },
          child: Text("Slide from left (originally top) to Page 6"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Slide top to Page 4"),
        ),
      ],
      bgColor: Colors.yellow,
    );
  }
}

class PageSix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      "Slide Left (originally Top) Page 6",
      [
        FlatButton(
          onPressed: () {
            AppNavigator.of(context).pushNamed("/7");
          },
          child: Text("Slide from left to Page 7"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Slide left to Page 5"),
        ),
      ],
      bgColor: Colors.yellow,
    );
  }
}

class PageSeven extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      "Slide Left Page 7",
      [
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Slide left to Page 6"),
        ),
      ],
    );
  }
}
