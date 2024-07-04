import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_color.dart';
import 'package:client/core/utils/extension.dart';
import 'package:client/core/utils/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongPage extends ConsumerStatefulWidget {
  const SongPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SongPageState();
}

class _SongPageState extends ConsumerState<SongPage> {
  @override
  Widget build(BuildContext context) {
    final recentlyPlayedSongs =
        ref.watch(homeViewModelProvider.notifier).getRecentlyPlayedSongs();
    final currentSong = ref.watch(currentSongNotifierProvider);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: currentSong == null
          ? null
          : BoxDecoration(
              gradient: LinearGradient(colors: [
                hexToColor(currentSong.hex_code),
                AppColor.transparentColor
              ], stops: const [
                0.0,
                0.30
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16,
              bottom: 36,
            ),
            child: SizedBox(
              height: 280,
              child: GridView.builder(
                itemCount: recentlyPlayedSongs.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8),
                itemBuilder: (context, index) {
                  final song = recentlyPlayedSongs[index];
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(currentSongNotifierProvider.notifier)
                          .updateSong(song);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                          color: AppColor.borderColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4)),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  song.thumbnail_url,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          8.horizontalSpacer,
                          Flexible(
                            child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              song.song_name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Latest today',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ref.watch(getAllSongsProvider).when(
                data: (songsList) {
                  return SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: songsList.length,
                      itemBuilder: (context, index) {
                        final song = songsList[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(currentSongNotifierProvider.notifier)
                                  .updateSong(song);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        song.thumbnail_url,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                5.verticalSpacer,
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    song.song_name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                5.verticalSpacer,
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    song.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: AppColor.subtitleText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                error: (error, st) {
                  return Center(
                    child: Text(
                      error.toString(),
                    ),
                  );
                },
                loading: () => const Loader(),
              )
        ],
      ),
    );
  }
}
