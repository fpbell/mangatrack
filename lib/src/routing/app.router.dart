import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mangatrack/src/features/bottom_nav_bar/presentation/bottom_nav_bar.screen.dart';
import 'package:mangatrack/src/routing/routes/app_route.router.dart';
import 'package:mangatrack/src/routing/routes/routes.router.dart';

// final _router = GoRouter(
//   initialLocation: '/',
//   routes: [
//     GoRoute(path: '/', builder: (context, state) => const MainShell()),
//     GoRoute(
//       path: '/viewer',
//       builder: (context, state) {
//         final imageUrl = state.extra as String;
//         return ImageViewerScreen(imageUrl: imageUrl);
//       },
//     ),
//   ],
// );

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
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // logger.i('PREVIOUS PAGE: ${previousRoute?.settings.name}');
    // logger.i('NEW PAGE: ${route.settings.name}');
    // logger.i('WITH ARGUMENTS: ${route.settings.arguments}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // logger.i('PREVIOUS PAGE: ${previousRoute?.settings.name}');
    // logger.i('NEW PAGE: ${route.settings.name}');
  }
}
