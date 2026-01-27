import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/_init/data/model/intro_item_model.dart';
import '../features/login/data/model/res_login_model.dart';
import 'user_model.dart';

/*class SharedPrefManager {
  static final SharedPrefManager _instance = SharedPrefManager._internal();

  factory SharedPrefManager() => _instance;

  SharedPrefManager._internal();

  static const String _keyUser = "app_users";
  static const String _keySettings = "app_settings";
  static const String _keyToken = "token";

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveUser(UserModal user) async {
    String userJson = jsonEncode(user.toMap());
    await _prefs.setString(_keyUser, userJson);
  }

  bool get isUserLogin => _prefs.getString(_keyUser) != null;

  UserModal? get user {
    String? data = _prefs.getString(_keyUser);
    if (data != null) {
      return UserModal.fromMap(jsonDecode(data));
    }
    return null;
  }

  InitAppModel? get settings {
    String? data = _prefs.getString(_keySettings);
    if (data != null && data.isNotEmpty) {
      return InitAppModel.fromMap(jsonDecode(data));
    }
    return null;
  }

  Future<void> userLogOut() async {
    await _prefs.remove(_keyUser);
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  Future<void> saveSettings(String settings) async {
    await _prefs.setString(_keySettings, settings);
  }

  String get userToken => _prefs.getString(_keyToken) ?? "";
}*/



class SharedPrefManager {
  static final SharedPrefManager _instance = SharedPrefManager._internal();
  factory SharedPrefManager() => _instance;
  SharedPrefManager._internal();

  static const String _keyLoginResponse = "login_response";
  static const String _keyToken = "token";

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save the whole LoginResponse model
  Future<void> saveLoginResponse(LoginResponse response) async {
    String jsonString = jsonEncode(response.toJson());
    await _prefs.setString(_keyLoginResponse, jsonString);
  }


  LoginResponse? get loginResponse {
    String? data = _prefs.getString(_keyLoginResponse);
    if (data != null && data.isNotEmpty) {
      return LoginResponse.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }


  bool get isLoggedIn {
    final loginData = loginResponse;
    return loginData != null &&
        loginData.data.token.isNotEmpty &&
        loginData.data.user.name.isNotEmpty;
  }

  String get userToken => _prefs.getString(_keyToken) ?? "";

  Future<void> userLogOut() async {
    await _prefs.remove(_keyLoginResponse);
    await _prefs.remove(_keyToken);
  }
}
