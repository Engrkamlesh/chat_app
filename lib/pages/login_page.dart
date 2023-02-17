import 'package:chai_chat_app/model/uihelper.dart';
import 'package:chai_chat_app/model/usermodel.dart';
import 'package:chai_chat_app/pages/home.dart';
import 'package:chai_chat_app/pages/sign_up.dart';
import 'package:chai_chat_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Login_Page extends StatefulWidget {
  const Login_Page({super.key});

  @override
  State<Login_Page> createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();

void login(String email , String password)async{
UserCredential? credential;
  UIHelper.showloadingDialog(context, "Logged in.....");
try{
  credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email, password: password);
}on FirebaseAuthException catch(ex){
  Navigator.pop(context);
  UIHelper.showAlertDialog(context, 'on Error Occured!',ex.message.toString());
  // Utils().ToastMassage(ex.toString());
}

if (credential != null) {
  String uid = credential.user!.uid;

  DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('users').doc(uid).get();

  UserModel userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
  Utils().ToastMassage('Welcome');
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home_Page(userModel: userModel, firebaseUser: credential!.user!)));
}

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child:Center(child:
          SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:Form(
            key: formkey,
            child:
           Column(
            children:[
              Text(
                'Chat App',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 20),
              TextFormField(
                validator: (value) {
                  if(value!.isEmpty){
                    return 'Required';
                  }
                  return null;
                },
                controller: emailcontroller,
                decoration: const InputDecoration(
                  label: Text('Email Password')
                ),
              ),
              const SizedBox(height: 10,),
              TextFormField(
                validator: (value) {
                  if(value!.isEmpty){
                      return 'Requied';
                  }
                  return null;
                },
                controller: passcontroller,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text('Password')
                ),
              ),
              const SizedBox(height: 30),
              CupertinoButton(
                onPressed: () {
                  if(formkey.currentState!.validate()){
                    login(emailcontroller.text.trim(), passcontroller.text.trim());
                  }
                },
                color: Colors.blue,
                child: const Text('Login'),
               ),
            ],
          ),
        )),
      )),),
        bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("If have't Account?"),
            CupertinoButton(child: const Text('Sign Up',style: TextStyle(fontSize: 15,color:Colors.blue,)),
             onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup_Page()));
            })
          ],
        ),
      ),
    );
  }
}
