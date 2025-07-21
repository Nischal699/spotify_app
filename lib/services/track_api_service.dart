import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../models/track.dart';

class TrackApiService {
  final String baseUrl;

  TrackApiService({required this.baseUrl});

  // GET all tracks
  Future<List<Track>> getTracks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tracks/all/'),
    ); // <-- FIXED

    print('🔍 GET ${response.request!.url}');
    print('📦 Status: ${response.statusCode}');
    print('📦 Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Track.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load tracks. Code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  // GET a track by id
  Future<Track> getTrack(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/tracks/$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Track.fromJson(data);
    } else {
      throw Exception('Failed to load track');
    }
  }

  // POST create a new track
  Future<Track> createTrack(Track track) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tracks/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(track.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Track.fromJson(data);
    } else {
      throw Exception('Failed to create track');
    }
  }

  // PUT update a track
  Future<Track> updateTrack(int id, Track track) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tracks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(track.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Track.fromJson(data);
    } else {
      throw Exception('Failed to update track');
    }
  }

  // DELETE a track
  Future<void> deleteTrack(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tracks/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete track');
    }
  }

  // Upload track with file (without token)
  Future<Track> uploadTrack({
    required String title,
    required String artist,
    String? album,
    int? duration,
    required File musicFile,
  }) async {
    final uri = Uri.parse('$baseUrl/tracks/');

    final request = http.MultipartRequest('POST', uri)
      ..fields['title'] = title
      ..fields['artist'] = artist
      ..fields['album'] = album ?? ''
      ..fields['duration'] = duration?.toString() ?? ''
      ..files.add(
        await http.MultipartFile.fromPath(
          'music_file',
          musicFile.path,
          filename: basename(musicFile.path),
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Track.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  }
}
