import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_bloc_app/core/config/flavors/flavors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static String get apiBaseUrl => FlavorConfig.instance.baseUrl;

  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    final key = (dotenv.env['SUPABASE_ANON_KEY'] ??
            dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
            '')
        .trim();
    if (url.isEmpty || key.isEmpty) return;

    await Supabase.initialize(
      url: url,
      publishableKey: key,
    );
  }

  static Future<Map<String, dynamic>> invokeFunction(
    String name, {
    Map<String, dynamic>? body,
    String method = 'POST',
    Map<String, dynamic>? queryParameters,
  }) async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = client.auth.currentSession?.accessToken;
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await dio.request<Map<String, dynamic>>(
        '/$name',
        data: body,
        queryParameters: queryParameters,
        options: Options(method: method, headers: headers),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Empty response from $name');
      }
      if (data['error'] != null) {
        throw Exception(data['error']);
      }
      return data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) {
        throw Exception(data['error']);
      }
      throw Exception(e.message ?? 'Request failed');
    }
  }
}
