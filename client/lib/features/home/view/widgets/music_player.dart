import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/utils/extension.dart';
import 'package:client/core/utils/utils.dart';

import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_color.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);

    final userFavorites = ref
        .watch(currentUserNotifierProvider.select((data) => data!.favorites));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            hexToColor(currentSong!.hex_code),
            const Color(0xff121212),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColor.transparentColor,
        appBar: AppBar(
          backgroundColor: AppColor.transparentColor,
          leading: Transform.translate(
            offset: const Offset(-15, 0),
            child: InkWell(
              highlightColor: AppColor.transparentColor,
              focusColor: AppColor.transparentColor,
              splashColor: AppColor.transparentColor,
              onTap: () {
                context.pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/pull-down-arrow.png',
                  color: AppColor.whiteColor,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Hero(
                  tag: 'music-image',
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          currentSong.thumbnail_url,
                        ),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSong.song_name,
                            style: const TextStyle(
                              color: AppColor.whiteColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            currentSong.artist,
                            style: const TextStyle(
                              color: AppColor.subtitleText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () async {
                          await ref
                              .read(homeViewModelProvider.notifier)
                              .favSong(
                                songId: currentSong.id,
                              );
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
                    ],
                  ),
                  15.verticalSpacer,
                  StreamBuilder(
                      stream: songNotifier.audioPlayer!.positionStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        }
                        final position = snapshot.data;
                        final duration = songNotifier.audioPlayer!.duration;

                        double sliderValue = 0.0;
                        if (position != null && duration != null) {
                          sliderValue =
                              position.inMilliseconds / duration.inMilliseconds;
                        }

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColor.whiteColor,
                                inactiveTrackColor:
                                    AppColor.whiteColor.withOpacity(0.117),
                                thumbColor: AppColor.whiteColor,
                                trackHeight: 4,
                                overlayShape: SliderComponentShape.noOverlay,
                              ),
                              child: Slider(
                                value: sliderValue,
                                min: 0,
                                max: 1,
                                onChanged: (val) {
                                  sliderValue = val;
                                },
                                onChangeEnd: songNotifier.seek,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${position?.inMinutes}:${(position?.inSeconds ?? 0) < 10 ? '0${position?.inSeconds}' : position?.inSeconds}',
                                  style: const TextStyle(
                                    color: AppColor.subtitleText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                                Text(
                                  '${duration?.inMinutes}:${(duration?.inSeconds ?? 0) < 10 ? '0${(duration?.inSeconds)}' : duration?.inSeconds}',
                                  style: const TextStyle(
                                    color: AppColor.subtitleText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                  15.verticalSpacer,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/shuffle.png',
                          color: AppColor.whiteColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/previus-song.png',
                          color: AppColor.whiteColor,
                        ),
                      ),
                      IconButton(
                        onPressed: songNotifier.playPause,
                        icon: Icon(
                          songNotifier.isPlaying
                              ? CupertinoIcons.pause_circle_fill
                              : CupertinoIcons.play_circle_fill,
                        ),
                        iconSize: 80,
                        color: AppColor.whiteColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/next-song.png',
                          color: AppColor.whiteColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/repeat.png',
                          color: AppColor.whiteColor,
                        ),
                      ),
                    ],
                  ),
                  25.verticalSpacer,
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/connect-device.png',
                          color: AppColor.whiteColor,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/playlist.png',
                          color: AppColor.whiteColor,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
