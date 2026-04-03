import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/screens/browse_screen.dart';
import 'package:mangatrack/screens/discover_screen.dart';
import 'package:mangatrack/screens/favourites_screen.dart';
import 'providers/bottom_nav_provider.dart';

enum BottomNav { home, fav, genre }

class BottomNavBar extends ConsumerWidget {
  final BottomNav? page;
  const BottomNavBar({super.key, this.page = BottomNav.home});

  static const List<Widget> _screens = [
    DiscoverScreen(),
    FavouritesScreen(),
    BrowseScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _screens[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) =>
              ref.read(bottomNavProvider.notifier).setIndex(index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favourites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Browse',
            ),
          ],
        ),
      ),
    );
  }
}
