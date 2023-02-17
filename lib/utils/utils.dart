import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class Utils{
    ToastMassage(String massage){
    return Fluttertoast.showToast(
      msg: massage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}