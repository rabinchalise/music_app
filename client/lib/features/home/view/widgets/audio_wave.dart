import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:client/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class AudioWave extends StatefulWidget {
  final String path;
  const AudioWave({
    super.key,
    required this.path,
  });

  @override
  State<AudioWave> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<AudioWave> {
  final PlayerController _playerController = PlayerController();

  @override
  void initState() {
    initAudioPlayer();
    super.initState();
  }

  void initAudioPlayer() async {
    await _playerController.preparePlayer(path: widget.path);
  }

  void playAndPauseAudio() async {
    if (!_playerController.playerState.isPlaying) {
      _playerController.startPlayer(finishMode: FinishMode.stop);
    } else if (!_playerController.playerState.isPaused) {
      _playerController.pausePlayer();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: playAndPauseAudio,
          icon: Icon(
            _playerController.playerState.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
          ),
        ),
        Expanded(
          child: AudioFileWaveforms(
              playerWaveStyle: const PlayerWaveStyle(
                  fixedWaveColor: AppColor.borderColor,
                  liveWaveColor: AppColor.gradient2,
                  spacing: 6,
                  showSeekLine: false),
              waveformType: WaveformType.long,
              size: const Size(double.infinity, 100),
              playerController: _playerController),
        ),
      ],
    );
  }
}
