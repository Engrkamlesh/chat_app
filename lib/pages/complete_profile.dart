// ignore_for_file: camel_case_types
import 'dart:io';
import 'package:chai_chat_app/model/uihelper.dart';
import 'package:chai_chat_app/model/usermodel.dart';
import 'package:chai_chat_app/pages/home.dart';
import 'package:chai_chat_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Complete_Profile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseuser;

  const Complete_Profile({super.key, required this.userModel, required this.firebaseuser});

  @override
  State<Complete_Profile> createState() => _Complete_ProfileState();
}

class _Complete_ProfileState extends State<Complete_Profile> {
  File? imagefile;
  TextEditingController fullnamecontroller = TextEditingController();

  void selectimage(ImageSource source)async{
    XFile? pickedfile = await ImagePicker().pickImage(source: source);

    if(pickedfile != null){
      cropImage(pickedfile);
    }
  }


  void cropImage(XFile file)async{
    CroppedFile? croppedImage =  await ImageCropper().cropImage(sourcePath: file.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressQuality: 20
    );

    if(croppedImage != null){
      setState(() {
        imagefile = File(croppedImage.path);
      });
    }
  }

  void showPhotoptions(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("Upload Profile Pic"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          ListTile(
            onTap: (){
              Navigator.pop(context);
              selectimage(ImageSource.gallery);
            },
            leading:const Icon(Icons.image),
            title:const Text('Upload Image Gallery'),
          ),
          ListTile(
            onTap: (){
              Navigator.pop(context);
              selectimage(ImageSource.camera);
            },
            leading:const Icon(Icons.camera),
            title:const Text('Take a Photo'),
          ),
        ],),
      );
    });
  }

  void checkvalues(){
    String fullname = fullnamecontroller.text.trim();

    if (fullname =='' || imagefile == null) {
      UIHelper.showAlertDialog(context,'Error Occured', 'Please fill the fields');
      // Utils().ToastMassage('Please Fill the fields');
    }else{
        updataData();
    }
  }

void updataData()async{
  UIHelper.showloadingDialog(context, "Uploading... Image");

  UploadTask uploadTask = FirebaseStorage.instance.ref("ProfilePic").
  child(widget.userModel.uid.toString()).putFile(imagefile!);

  TaskSnapshot snapshot = await uploadTask;

  String imageurl = await snapshot.ref.getDownloadURL();
  String fullname = fullnamecontroller.text.trim();

  widget.userModel.fullname = fullname;
  widget.userModel.profilepic = imageurl;

  await FirebaseFirestore.instance.collection('users').doc(
    widget.userModel.uid).set(widget.userModel.toMap()).
    then((value){
    Utils().ToastMassage('Image Uploaded');
     Navigator.popUntil(context, (route) => route.isFirst);
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
      return Home_Page(userModel: widget.userModel,
       firebaseUser: widget.firebaseuser);
     }));
  });

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,title: const Text('Profile'),),
      body:Center(child:
      Padding(padding:const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(children: [
        const SizedBox(height: 40),
        CupertinoButton(
            child: CircleAvatar(
              radius: 60,
              backgroundImage:(imagefile !=null)?FileImage(imagefile!):null,
              child:(imagefile ==null)?const Icon(Icons.person,size: 40,):null,), onPressed:(){
              showPhotoptions();
        }),
        const SizedBox(height: 20),
        TextField(
          controller: fullnamecontroller,
          decoration: InputDecoration(
            label: Text('Full Name'),
          ),
        ),
        const SizedBox(height: 30),
        CupertinoButton(
            color: Theme.of(context).colorScheme.secondary,
            child: const Text('Submit'), onPressed:(){
              checkvalues();
            })
      ],),),),
    );
  }
}