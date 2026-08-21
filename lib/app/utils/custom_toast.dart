import 'package:app/app/utils/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
///white colored toast
void toastMessage(String msg, Toast? toastLength) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: toastLength,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black45,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
///show a red colored toast, default duration:1 sec
void toastErrorMessage(String msg, {Toast? toastLength}) {
  Fluttertoast.showToast(
    msg: msg,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.redAccent,
    textColor: Colors.white,
    fontSize: 16.0,
    toastLength: toastLength??Toast.LENGTH_SHORT,
  );
}
///show a green colored toast, default duration:1 sec
void toastSuccessMessage(String msg, {Toast? toastLength,ToastGravity? gravity}) {
  Fluttertoast.showToast(
    msg: msg,
    gravity:gravity?? ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: ColorManager.kPrimaryLight,
    textColor: Colors.black,
    fontSize: 16.0,
    toastLength: toastLength??Toast.LENGTH_SHORT,
  );
}
///show a work in progress toast, default duration:1 sec
void toastWorkInProgressMessage() {
  Fluttertoast.showToast(
    msg: "Work in progress",
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: ColorManager.kPrimaryLight,
    textColor: Colors.black,
    fontSize: 16.0,
  );
}
