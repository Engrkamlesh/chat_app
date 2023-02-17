import 'package:chai_chat_app/model/uihelper.dart';
import 'package:chai_chat_app/pages/complete_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/usermodel.dart';
import '../utils/utils.dart';

class Signup_Page extends StatefulWidget {
  const Signup_Page({super.key});

  @override
  State<Signup_Page> createState() => _Signup_PageState();
}

class _Signup_PageState extends State<Signup_Page> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController cpasswordcontroller = TextEditingController();

void signup(String email, String password)async{
    UserCredential? credential;

    UIHelper.showloadingDialog(context, "Creating New Account");
    try{
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password);
    }on FirebaseAuthException catch(ex){
      UIHelper.showAlertDialog(context,'an Error Occured!', ex.message.toString());
      // Utils().ToastMassage(ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: '',
        profilepic: ''
      );
      await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.toMap()).then((value){
        Utils().ToastMassage('Successfully');
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)
        =>Complete_Profile(userModel: newUser, firebaseuser: credential!.user!)));
      }).onError((error, stackTrace){
        // ignore: avoid_print
        print(error);
        Utils().ToastMassage(error.toString());
      });
    }else{
      Utils().ToastMassage('something wrong');
    }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child:Center(
              child:SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Chat App',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary,fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                 TextFormField(
                  validator:(value){
                    if (value!.isEmpty) {
                      return 'Requird';
                    }else{
                      return null;
                    }
                  } ,
                  controller: emailcontroller,
                  decoration:const InputDecoration(label: Text('Email Password'),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
               TextFormField(
                validator: (value){
                  if (value!.isEmpty) {
                    return 'Required';
                  }else{
                    return null;
                  }
                },
                controller: passwordcontroller,
                  obscureText: true,
                  decoration: const InputDecoration(label: Text('Password')),
                ),
                 const SizedBox(
                  height: 10,
                ),
               TextFormField(
                validator:(value) {
                  if (value!.isEmpty) {
                    return 'Required';
                  }
                  else{
                    return null;
                  }
                },
                controller: cpasswordcontroller,
                  obscureText: true,
                  decoration: const InputDecoration(label: Text('Confirm Password')),
                ),
                const SizedBox(height: 30),
                CupertinoButton(
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      signup(emailcontroller.text.trim(), passwordcontroller.text.trim());
                    }
                  },
                  color: Theme.of(context).colorScheme.secondary,
                  child: const Text('Sign Up') ,
                ),
              ],
            ),
          ),
        ),
      ))
    ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Already have an account?'),
            CupertinoButton(child: const Text('Log In'), onPressed: (){
              Navigator.pop(context);
            })
          ],
        ),
      ),
    );
  }
}
