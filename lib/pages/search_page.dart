// ignore_for_file: use_build_context_synchronously, camel_case_types
import 'dart:math';
import 'package:chai_chat_app/model/chatroom.dart';
import 'package:chai_chat_app/model/usermodel.dart';
import 'package:chai_chat_app/pages/chatroom_page.dart';
import 'package:chai_chat_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Search_Page extends StatefulWidget {
  final UserModel userModel;
  final User  firebaseUser;

  const Search_Page({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<Search_Page> createState() => _Search_PageState();
}

class _Search_PageState extends State<Search_Page> {
TextEditingController searchcontroller = TextEditingController();
var uuid = const Uuid();

Future<ChatRoomModel?> getChatroomModel(UserModel targetUser)async{
  ChatRoomModel? chatroom;
  
  QuerySnapshot snapshot =  await FirebaseFirestore.instance.collection('chatroom').where(
    'participents.${widget.userModel.uid}',isEqualTo: true
  ).where( 'participents.${targetUser.uid }',isEqualTo: true).get();
 
 if (snapshot.docs.length > 0) {
  //fetch the existing data  
  Utils().ToastMassage('Chatroom already created');
 var docData = snapshot.docs[0].data();
  ChatRoomModel existingchatroom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);
  chatroom = existingchatroom;  
 }else{
  Utils().ToastMassage('chatroom not created');
  
  ChatRoomModel newChatroom = ChatRoomModel(
    chatroomid: uuid.v1(),
    lastmessage: '',
    participents: {
      widget.userModel.uid.toString() : true,
      targetUser.uid.toString() : true,
    }
  );

  await FirebaseFirestore.instance.collection('chatroom').doc(
    newChatroom.chatroomid
  ).set(newChatroom.toMap());

  chatroom = newChatroom;
  Utils().ToastMassage('New chatroom created');
 } 
return chatroom;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back_ios,color: Colors.black,)),
        title: const Text('Search',style: TextStyle(color: Colors.black),),centerTitle: true,),
      body: SafeArea(child:Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: 
       Column(
        children: [
          TextFormField(
            controller: searchcontroller,
            decoration:const InputDecoration(
              label: Text('something search')
            ),
          ),
          const SizedBox(height: 20),
          CupertinoButton(child: const Text('Search'), onPressed: (){
          setState(() {

          });
          },color: Theme.of(context).colorScheme.secondary,),
         const SizedBox(height: 20),

         StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').
          where('email', isEqualTo: searchcontroller.text).where('email', isNotEqualTo: widget.userModel.email).snapshots(),
          builder: (context, index){
            if(index.connectionState == ConnectionState.active){
              if(index.hasData){
                QuerySnapshot querySnapshot = index.data as QuerySnapshot;

              if(querySnapshot.docs.length > 0) {

                Map<String, dynamic> userMap = querySnapshot.docs[0].data() as Map<String, dynamic>;
                
                UserModel searchedUser = UserModel.fromMap(userMap);

                return ListTile(
                  onTap:() async{
                    ChatRoomModel? chatroomModel = await getChatroomModel(searchedUser);  
                    if(chatroomModel != null){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>Chat_Room(
                        targetUser: searchedUser,
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser,
                      chatroom:chatroomModel ,)));
                  }},
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(searchedUser.profilepic!),
                  ),
                  title: Text(searchedUser.fullname!),
                  subtitle: Text(searchedUser.email!),
                );
              }else{
                return const Text('no result Found!');
              }
              }else if(index.hasError){
                return const Text('Error Occurred!');
              }else{
                return const Text('No Result Found!');
              }
            }else{
              return const CircularProgressIndicator(color: Colors.black45,);
            }
          })        
        ],
      )),
    ));
  }
}