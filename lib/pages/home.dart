// ignore_for_file: use_build_context_synchronously, avoid_unnecessary_containers, non_constant_identifier_names, camel_case_types
import 'package:chai_chat_app/model/chatroom.dart';
import 'package:chai_chat_app/pages/chatroom_page.dart';
import 'package:chai_chat_app/pages/firebasehelper.dart';
import 'package:chai_chat_app/pages/login_page.dart';
import 'package:chai_chat_app/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/usermodel.dart';

class Home_Page extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const Home_Page(
      {super.key, required this.userModel, required this.firebaseUser});
  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton(
              icon: const Icon(
                Icons.more_vert_outlined,
                color: Colors.black,
              ),
              itemBuilder: (context) => [
                     PopupMenuItem(child: TextButton(onPressed:(){}, child:const Text('Profile',
                     style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300,color: Colors.black),),)),
                       PopupMenuItem(child: TextButton(onPressed:(){}, child:const Text('New group',
                     style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300,color: Colors.black),),)),
                       PopupMenuItem(child: TextButton(onPressed:(){}, child:const Text('Setting',
                     style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300,color: Colors.black),),)),
                    PopupMenuItem(
                        child: TextButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Login_Page()));
                            },
                            child: Text("Logout",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300,color: Colors.black),)))
                  ]),
        ],
        title: const Text(
          'Messages!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SafeArea(
          child: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatroom')
              .where("participents.${widget.userModel.uid}", isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot Chatroomsnapshot = snapshot.data as QuerySnapshot;
                return ListView.builder(
                    itemCount: Chatroomsnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          Chatroomsnapshot.docs[index].data()
                              as Map<String, dynamic>);
                      Map<String, dynamic> participants =
                          chatRoomModel.participents!;
                      List<String> participantkeys = participants.keys.toList();
                      participantkeys.remove(widget.userModel.uid);
                      return FutureBuilder(
                          future: FirebaseHelper.getuserModelbyid(
                              participantkeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              if (userData.data != null) {
                                UserModel targetUser =
                                    userData.data as UserModel;
                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Chat_Room(
                                                targetUser: targetUser,
                                                chatroom: chatRoomModel,
                                                userModel: widget.userModel,
                                                firebaseUser:
                                                    widget.firebaseUser)));
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green,
                                    backgroundImage: NetworkImage(
                                        targetUser.profilepic.toString()),
                                  ),
                                  title: Text(targetUser.fullname.toString()),
                                  subtitle: (chatRoomModel.lastmessage
                                              .toString() !=
                                          '')
                                      ? Text(
                                          chatRoomModel.lastmessage.toString())
                                      : Text(
                                          'say hi to your firends!',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            } else {
                              return Container();
                            }
                          });
                    });
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(
                  child: Text('No Chats'),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Search_Page(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser)));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
