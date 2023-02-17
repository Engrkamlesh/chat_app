import 'package:chai_chat_app/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper{


  static Future<UserModel?> getuserModelbyid(String uid)async{

    UserModel? userModel;

    DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (docSnap.data() != null) {
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }
    return userModel;
  }
}