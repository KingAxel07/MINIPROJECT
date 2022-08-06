import 'package:flutter/material.dart';
import 'package:get/get.dart';

showErrorDialog(BuildContext context, {String? message = "Error"}) {
  Get.snackbar(
    message!,
    'Server Error',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red,
    colorText: Colors.white,
    icon: Icon(Icons.error, color: Colors.white),
    duration: Duration(seconds: 2),
  );
}
