import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_color.dart';
import 'package:client/core/utils/extension.dart';
import 'package:client/core/utils/utils.dart';
import 'package:client/features/home/view/widgets/music_player.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicSlab extends ConsumerWidget {
  const MusicSlab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);
    final userFavorites = ref.watch(
      currentUserNotifierProvider.select((data) => data!.favorites),
    );
    final screenWidth = context.width;
    if (currentSong == null) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const MusicPlayer();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween =
                Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
              CurveTween(curve: Curves.easeIn),
            );
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ));
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(9),
            height: 66,
            width: screenWidth - 16,
            decoration: BoxDecoration(
              color: hexToColor(currentSong.hex_code),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'music-image',
                      child: Container(
                        width: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              currentSong.thumbnail_url,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    8.horizontalSpacer,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentSong.song_name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          currentSong.artist,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColor.subtitleText,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await ref
                            .read(homeViewModelProvider.notifier)
                            .favSong(songId: currentSong.id);
                      },
                      icon: Icon(
                        userFavorites
                                .where((fav) => fav.song_id == currentSong.id)
                                .toList()
                                .isNotEmpty
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: AppColor.whiteColor,
                      ),
                    ),
                    IconButton(
                      onPressed: songNotifier.playPause,
                      icon: Icon(
                        songNotifier.isPlaying
                            ? CupertinoIcons.pause_fill
                            : CupertinoIcons.play_fill,
                        color: AppColor.whiteColor,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          StreamBuilder(
              stream: songNotifier.audioPlayer?.positionStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                final position = snapshot.data;
                final duration = songNotifier.audioPlayer!.duration;
                double silderValue = 0.0;
                if (position != null && duration != null) {
                  silderValue =
                      position.inMilliseconds / duration.inMilliseconds;
                }

                return Positioned(
                  left: 8,
                  bottom: 0,
                  child: Container(
                    height: 3,
                    width: silderValue * (screenWidth - 32),
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                );
              }),
          Positioned(
            left: 8,
            bottom: 0,
            child: Container(
              height: 3,
              width: screenWidth - 32,
              decoration: BoxDecoration(
                color: AppColor.inactiveSeekColor,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
