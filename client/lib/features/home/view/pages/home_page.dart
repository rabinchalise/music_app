import 'package:client/core/theme/app_color.dart';
import 'package:client/features/home/view/pages/libary_page.dart';
import 'package:client/features/home/view/pages/search_page.dart';
import 'package:client/features/home/view/pages/song_page.dart';
import 'package:client/features/home/view/widgets/music_slab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int selectedIndex = 0;

  final pages = [
    const SongPage(),
    const SearchPage(),
    const LibraryPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(
                selectedIndex == 0
                    ? 'assets/images/home_filled.png'
                    : 'assets/images/home_unfilled.png',
                color: selectedIndex == 0
                    ? AppColor.whiteColor
                    : AppColor.inactiveBottomBarItemColor,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Image.asset(
                selectedIndex == 1
                    ? 'assets/images/search_filled.png'
                    : 'assets/images/search_unfilled.png',
                color: selectedIndex == 1
                    ? AppColor.whiteColor
                    : AppColor.inactiveBottomBarItemColor,
              ),
              label: 'Search'),
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/library.png',
                color: selectedIndex == 2
                    ? AppColor.whiteColor
                    : AppColor.inactiveBottomBarItemColor,
              ),
              label: 'Library')
        ],
      ),
      body: Stack(
        children: [
          pages[selectedIndex],
          const Positioned(
            bottom: 0,
            child: MusicSlab(),
          ),
        ],
      ),
    );
  }
}
