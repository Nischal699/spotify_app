class Track {
  int? id;
  String title;
  String artist;
  String? album;
  int? duration;
  String? fileUrl;

  static const String _baseUrl = 'https://spotify-api-pytj.onrender.com';

  Track({
    this.id,
    required this.title,
    required this.artist,
    this.album,
    this.duration,
    this.fileUrl,
  });

  // ✅ Computed getter for full audio URL
  String get fullAudioUrl {
    if (fileUrl == null || fileUrl!.isEmpty) return '';
    return '$_baseUrl$fileUrl';
  }

  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: json['id'],
    title: json['title'],
    artist: json['artist'],
    album: json['album'],
    duration: json['duration'],
    fileUrl: json['file_url'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'title': title,
    'artist': artist,
    if (album != null) 'album': album,
    if (duration != null) 'duration': duration,
    if (fileUrl != null) 'file_url': fileUrl,
  };
}
