class ChatRoomModel{
  String? chatroomid;
  Map<String, dynamic>? participents;
  String? lastmessage;

  ChatRoomModel({this.chatroomid, this.participents,this.lastmessage});

  ChatRoomModel.fromMap(Map<String, dynamic> map){
    chatroomid = map['chatroomid'];
    participents = map['participents'];
    lastmessage = map['lastmessage'];
  } 

  Map<String, dynamic> toMap(){
    return {
      'chatroomid' : chatroomid,
      'participents' : participents,
      'lastmessage' : lastmessage,
    };
  }
}