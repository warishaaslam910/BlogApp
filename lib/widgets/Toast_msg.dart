import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toast_msg {
  void showMsg(String text) {
    Fluttertoast.showToast(
        msg: text.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.indigo,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
