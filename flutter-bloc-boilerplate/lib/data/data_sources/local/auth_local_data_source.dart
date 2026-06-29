import 'dart:convert';

import 'package:my_bloc_app/core/dio/auth_token_provider.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource implements AuthTokenProvider {
  Future<void> saveUser(UserEntity user);
  Future<UserEntity?> getUser();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _tokenKey = 'access_token';
  static const _userKey = 'user_data';

  @override
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.accessToken != null) {
      await prefs.setString(_tokenKey, user.accessToken!);
    }
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserEntity?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return UserEntity.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
