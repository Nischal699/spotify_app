import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late String title;
  late String audioUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    title = args['title'] ?? 'Unknown Title';
    audioUrl = args['audioUrl'] ?? '';

    // Set audio only once
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.setAudio(audioUrl);
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album art placeholder
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade900,
              ),
              child: const Icon(
                Icons.music_note,
                color: Colors.white54,
                size: 120,
              ),
            ),
            const SizedBox(height: 40),

            // Song title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Artist placeholder
            const Text(
              'Artist Name',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Progress slider with times
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(audioProvider.currentPosition),
                  style: const TextStyle(color: Colors.white70),
                ),
                Expanded(
                  child: Slider(
                    activeColor: Colors.amber,
                    inactiveColor: Colors.white24,
                    value: audioProvider.currentPosition.inSeconds
                        .toDouble()
                        .clamp(0, audioProvider.duration.inSeconds.toDouble()),
                    min: 0,
                    max: audioProvider.duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      audioProvider.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                Text(
                  _formatDuration(audioProvider.duration),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Play/Pause button
            IconButton(
              iconSize: 80,
              color: Colors.amber,
              icon: Icon(
                audioProvider.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
              ),
              onPressed: () {
                audioProvider.playPause();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
