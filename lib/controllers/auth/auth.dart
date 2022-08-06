import 'dart:convert';
import 'dart:io';

import 'package:elibrary/model/user.dart';
import 'package:elibrary/services/auth/auth.dart';
import 'package:elibrary/services/endpoints/endpoints.dart';
import 'package:elibrary/utils/shared_prefs.dart';
import 'package:elibrary/views/auth/login/login.dart';
import 'package:elibrary/widgets/button_nav.dart';
import 'package:elibrary/widgets/error.dart';
import 'package:elibrary/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  AuthService authService = AuthService();
  ProjectApis projectApis = ProjectApis();

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  var isPasswordHidden = true.obs;

  Future createUserAccount(BuildContext context) async {
    showLoaderDialog(context, message: "signing up ...");

    http.Response response = await authService.signUpUser(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    print(response.body);
    print("response got here");
    print(response.statusCode);
    if (response.statusCode == 200 && response.body != "") {
      Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      if (responseData["status"] == true) {
        var user = User.fromJson(responseData["data"]);
        print("registering: token=${user.token}");
        Directory documentDirectory = await getApplicationDocumentsDirectory();
        user.applicationDirPath = documentDirectory.path;
        UserPreferences().setUser(user);
        Navigator.pop(context);
        Get.offAll(() => BottomNavigation());

        Get.snackbar(
          "Registration Successful",
          responseData['message'],
        );

        return;
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['message']),
        ));
        return;
      }
    } else {
      Navigator.pop(context);

      showErrorDialog(context, message: "Server Error");
      return;
    }
  }

  Future loginUser(BuildContext context) async {
    showLoaderDialog(context, message: 'Logging in...');

    http.Response response = await authService.signInUser(
      email,
      password,
    );
    if (response.statusCode == 200 || response.body != '') {
      Map<String, dynamic> responseData = json.decode(response.body);
      debugPrint(responseData.toString());
      if (responseData['status'] == 'success') {
        var userData = User.fromJson(responseData['data']);
        debugPrint("login: token=${userData.token}");
        Directory documentDirectory = await getApplicationDocumentsDirectory();
        userData.applicationDirPath = documentDirectory.path;
        UserPreferences().setUser(userData);
        Navigator.pop(context);
        Get.offAll(() => BottomNavigation());
        return;
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['message']),
        ));
        return;
      }
    } else {
      Navigator.pop(context);

      showErrorDialog(context, message: "Server Error");
      return;
    }
  }

  Future signOut() async {
    await authService.signOutUser();
    Get.offAll(() => LoginScreen());
  }
}
