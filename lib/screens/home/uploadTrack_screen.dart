import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:spotify/services/track_api_service.dart';

class UploadTrackScreen extends StatefulWidget {
  final TrackApiService apiService;

  const UploadTrackScreen({super.key, required this.apiService});

  @override
  State<UploadTrackScreen> createState() => _UploadTrackScreenState();
}

class _UploadTrackScreenState extends State<UploadTrackScreen> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  File? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) return;

    try {
      await widget.apiService.uploadTrack(
        title: _titleController.text,
        artist: _artistController.text,
        musicFile: _selectedFile!,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload successful")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Track')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _artistController,
              decoration: const InputDecoration(labelText: 'Artist'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.music_note),
              label: Text(
                _selectedFile != null ? 'File selected' : 'Pick Audio File',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _upload,
              icon: const Icon(Icons.upload),
              label: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
