import 'package:go_router/go_router.dart';
import 'package:mangatrack/src/features/bottom_nav_bar/presentation/bottom_nav_bar.screen.dart';
import 'package:mangatrack/src/features/discover/presentation/screens/image_viewer_screen.dart';
import 'package:mangatrack/src/routing/routes/routes.router.dart';

final List<GoRoute> appRoute = [
  GoRoute(
    path: '/viewer',
    builder: (context, state) {
      final imageUrl = state.extra as String?;
      return ImageViewerScreen(
        imageUrl: imageUrl ?? 'https://picsum.photos/id/25/600/3000',
      );
    },
  ),
];
