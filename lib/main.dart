import 'package:chai_chat_app/model/usermodel.dart';
import 'package:chai_chat_app/pages/firebasehelper.dart';
import 'package:chai_chat_app/pages/home.dart';
import 'package:chai_chat_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentusers = FirebaseAuth.instance.currentUser;

  if (currentusers != null) {
    
    UserModel? thisuserModel = await FirebaseHelper.getuserModelbyid(currentusers.uid);

    if (thisuserModel != null) {
    runApp(MyAppLogged(userModel: thisuserModel, firebaseUser: currentusers)); 
    }else{
      runApp(const MyApp());
    }
  }else{
  runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login_Page(),
    );
  }
}


class MyAppLogged extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLogged({super.key, required this.userModel, required this.firebaseUser});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Home_Page(userModel: userModel, firebaseUser: firebaseUser)
    );
  }
}
