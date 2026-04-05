import 'package:go_router/go_router.dart';
import 'package:mangatrack/src/features/image_viewer/image_viewer_screen.dart';

final List<GoRoute> appRoute = [
  GoRoute(
    path: '/viewer',
    builder: (context, state) {
      // ← extra is now a Map instead of a plain String
      final extra = state.extra as Map<String, dynamic>?;
      return ImageViewerScreen(
        imageUrl:
            extra?['imageUrl'] as String? ??
            'https://picsum.photos/id/25/600/3000',
        title: extra?['title'] as String?,
      );
    },
  ),
];
