import 'package:chai_chat_app/model/chatroom.dart';
import 'package:chai_chat_app/model/message.dart';
import 'package:chai_chat_app/model/usermodel.dart';
import 'package:chai_chat_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Chat_Room extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const Chat_Room(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<Chat_Room> createState() => _Chat_RoomState();
}

class _Chat_RoomState extends State<Chat_Room> {
  TextEditingController messagecontroller = TextEditingController();
  var uuid = const Uuid();

  void sendMessage() async {
    String msg = messagecontroller.text.trim();
    messagecontroller.clear();

    if (msg != "") {
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false); 
 
      FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatroom.chatroomid)
          .collection('messages')
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastmessage = msg;
      Utils().ToastMassage("message was sending");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            height: 35,
            width: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle
            )
            ,child: Icon(Icons.phone_outlined,size: 18,),),
          SizedBox(width: 10),
          
          Container(
            height: 35,
            width: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle
            )
            ,child: Icon(Icons.video_call_outlined,size: 18,),),
          SizedBox(width: 10),
        ],
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.grey,),),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            const SizedBox(width: 10),
            Text(widget.targetUser.fullname.toString(),style: TextStyle(color: Colors.black),)
          ],
        ),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chatroom')
                  .doc(widget.chatroom.chatroomid)
                  .collection('messages')
                  .orderBy('createdon', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot datasnapshot = snapshot.data as QuerySnapshot;
                    return ListView.builder(
                        reverse: true,
                        itemCount: datasnapshot.docs.length,
                        itemBuilder: (context, index) {
                          MessageModel currentMessage = MessageModel.fromMap(
                              datasnapshot.docs[index].data()
                                  as Map<String, dynamic>);
                        
                        // return Text(currentMessage.sender.toString());
                          return Row(
                            mainAxisAlignment:
                                (currentMessage.sender == widget.userModel.uid)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: (currentMessage.sender ==
                                              widget.userModel.uid)
                                          ? Colors.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                  child: Text(
                                    currentMessage.text.toString(),
                                    style: TextStyle(color: (currentMessage.sender ==
                                              widget.userModel.uid)
                                          ? Colors.black: Colors.white),
                                  )),
                            ],
                          );
                        });
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                          'An Error occured! Please check your internet connection.'),
                    );
                  } else {
                    return const Center(
                      child: Text('Say hi to your new friend'),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                    ),
                  );
                }
              },
            ),
          )),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
              Icon(Icons.emoji_emotions_outlined,color: Theme.of(context).colorScheme.secondary,),
              SizedBox(width: 14),
                Flexible(
                    child: TextField(
                  controller: messagecontroller,
                  maxLines: null,
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Enter message!'),
                )),
                IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.secondary,
                    ))
              ],
            ),
          )
        ],
      )),
    );
  }
}
