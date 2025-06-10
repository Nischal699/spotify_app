import 'package:dio/dio.dart';
import '../constants.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<dynamic> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': email, 'password': password},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ), // <-- inside post()
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        print('Login error response: ${e.response?.data}');
      } else {
        print('Login error: ${e.message}');
      }
      return null;
    } catch (e) {
      print('Unexpected login error: $e');
      return null;
    }
  }

  Future<dynamic> register(String email, String password) async {
    try {
      final response = await _dio.post(
        '/users',
        data: {'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.data;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }
}
