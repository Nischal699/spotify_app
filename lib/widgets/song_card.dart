import 'package:flutter/material.dart';
import 'package:spotify/routes/app_routes.dart';

class SongCard extends StatelessWidget {
  final String title;
  final String audioUrl;

  const SongCard({super.key, required this.title, required this.audioUrl});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.player,
          arguments: {'title': title, 'audioUrl': audioUrl},
        );
      },
    );
  }
}
