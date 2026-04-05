import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/core/theme/app_theme.dart';
import 'package:mangatrack/src/routing/app.router.dart';

void main() => runApp(const ProviderScope(child: MangaTrackApp()));

class MangaTrackApp extends ConsumerWidget {
  const MangaTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'MangaTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: goRouter,
    );
  }
}
