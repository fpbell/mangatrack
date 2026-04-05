import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mangatrack/src/features/bottom_nav_bar/presentation/bottom_nav_bar.screen.dart';
import 'package:mangatrack/src/routing/routes/app_route.router.dart';
import 'package:mangatrack/src/routing/routes/routes.router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  observers: [MyNavigatorObserver()],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BottomNavBar(),
      name: AppRoute.homepage.name,
    ),
    ...appRoute,
  ],
  errorBuilder: (context, state) =>
      Center(child: ErrorWidget(state.error ?? 'Unexpected Error')),
);

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {}
}
