import 'dart:convert';
import 'dart:io';

import 'package:elibrary/model/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserPreferences {
  Future setSeenOnboard() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('seenOnboard', true);
    return true;
  }

  Future<bool> setUser(User user) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    //  preferences.setString('user', json.encode(user));

    preferences.setString("name", user.name);
    preferences.setString("email", user.email);
    preferences.setString("api_token", user.token);
    return true;
  }

  Future<User?> getUser() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    String name = preferences.getString("name").toString();
    String email = preferences.getString("email").toString();

    String token = preferences.getString("api_token").toString();
    // int id = preferences.getInt("id");

    // User user = User(
    //   name: name,
    //   email: email,
    //   token: token,
    //   id: id,
    // );

    Directory documentDirectory = await getApplicationDocumentsDirectory();
    print("documentDirectory.path:${documentDirectory.path}");
    // user.applicationDirPath = documentDirectory.path;

    // return user;
  }

  removeUser() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }

  Future<String?> getUserToken() async {
    return getUserValue("api_token");
  }

  Future<int?> getUserId() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    int? value = preferences.getInt("id");
    return value;
  }

  Future<String?> getUserValue(args) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? value = preferences.getString(args);
    return value;
  }
}
