import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      home: _MusicPlayerScreen(),
    );
  }
}

class _MusicPlayerScreen extends StatefulWidget {
  const _MusicPlayerScreen({super.key});

  @override
  State<_MusicPlayerScreen> createState() => __MusicPlayerScreenState();
}

class __MusicPlayerScreenState extends State<_MusicPlayerScreen> {
  late AudioPlayer _player;
  final List<String> playList = [
    "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadTrack();
  }

  Future<void> _loadTrack() async {
    await _player.setUrl(playList[currentIndex]);
    _player.play();
  }

  void _nextTrack() {
    setState(() {
      currentIndex = (currentIndex + 1) % playList.length;
    });
    _loadTrack();
  }

  void _previousTrack() {
    setState(() {
      currentIndex = (currentIndex - 1 + playList.length) % playList.length;
    });
    _loadTrack();
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Player')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<Duration?>(
            stream: _player.durationStream,
            builder: (context, snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration?>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Slider(
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds
                            .clamp(0, duration.inSeconds)
                            .toDouble(),
                        onChanged: (value) {
                          _player.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                      Text(
                        "${position.toString().split('.').first} / ${duration.toString().split('.').first}",
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _previousTrack,
                icon: Icon(Icons.skip_previous, size: 40),
              ),
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final isPlaying = playerState?.playing ?? false;
                  if (isPlaying) {
                    return IconButton(
                      onPressed: _player.pause,
                      icon: Icon(Icons.pause, size: 50),
                    );
                  } else {
                    return IconButton(
                      onPressed: _player.play,
                      icon: Icon(Icons.play_arrow, size: 50),
                    );
                  }
                },
              ),
              IconButton(
                onPressed: _nextTrack,
                icon: Icon(Icons.skip_next, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
