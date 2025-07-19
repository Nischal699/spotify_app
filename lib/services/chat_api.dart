import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:spotify/models/message.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<List<Message>> fetchMessageHistory(int userId, int otherUserId) async {
  final token = await secureStorage.read(key: "access_token");

  final response = await http.get(
    Uri.parse(
      'http://spotify-api-pytj.onrender.com/chat/history?user_id=$userId&other_user_id=$otherUserId',
    ),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Message.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load messages');
  }
}
