import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify/providers/audio_provider.dart'; // <-- import your provider
import 'package:spotify/routes/app_routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AudioProvider())],
      child: const Spotify(),
    ),
  );
}

class Spotify extends StatelessWidget {
  const Spotify({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/splash',
      routes: AppRoutes.routes,
    );
  }
}
