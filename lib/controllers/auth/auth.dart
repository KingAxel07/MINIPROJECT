import 'dart:convert';

import 'package:elibrary/model/api_response.dart';
import 'package:elibrary/model/user.dart';
import 'package:elibrary/services/auth/auth.dart';
import 'package:elibrary/services/endpoints/endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  AuthService authService = AuthService();
  ProjectApis projectApis = ProjectApis();

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  var isPasswordHidden = true.obs;

  Future loginUser() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      http.Response response = await authService.signInUser(email, password);
      debugPrint("This is the body: ${response.body}");

      print(response.statusCode);

      switch (response.statusCode) {
        case 200:
          apiResponse.data = User.fromJson(json.decode(response.body));
          apiResponse.message = "success";
          break;
        case 422:
          final error = json.decode(response.body)['errors'];
          apiResponse.message = error[error.keys.elementAt(0)][0];
          break;
        case 401:
          apiResponse.message = json.decode(response.body)['message'];
          break;
        default:
          apiResponse.message = projectApis.errorMessage;
          break;
      }
    } catch (e) {
      apiResponse.message = projectApis.errorMessageServer;
    }
    return apiResponse;
  }

  Future register(String name, String email, String password) async {
    ApiResponse apiResponse = ApiResponse();

    try {
      http.Response response =
          await authService.signUpUser(name, email, password, confirmPassword);
      debugPrint("This is the body: ${response.body}");

      // print(response.statusCode);

      switch (response.statusCode) {
        case 200:
          apiResponse.data = User.fromJson(json.decode(response.body));
          apiResponse.message = "success";
          break;
        case 422:
          final error = json.decode(response.body)['errors'];
          apiResponse.message = error[error.keys.elementAt(0)][0];
          break;
        default:
          apiResponse.message = projectApis.errorMessage;
          break;
      }
    } catch (e) {
      apiResponse.message = projectApis.errorMessageServer;
    }

    return apiResponse;
  }

  // Retrieve User Data
  Future<ApiResponse> getUserData() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      String token = await getUserToken();
      final response = await http.get(
        Uri.parse(projectApis.userUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      switch (response.statusCode) {
        case 200:
          apiResponse.data = User.fromJson(json.decode(response.body));
          break;
        case 401:
          apiResponse.message = projectApis.errorMessageUnauthorized;
          break;
        default:
          apiResponse.message = projectApis.errorMessage;
          break;
      }
    } catch (e) {
      apiResponse.message = projectApis.errorMessageServer;
    }

    return apiResponse;
  }

  // Retrieve User token using shared preferences
  Future<String> getUserToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("token") ?? "";
  }

  // Retrieve User ID
  Future<int> getUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt("userId") ?? 0;
  }

  Future<bool> logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.remove("token");
  }
}
