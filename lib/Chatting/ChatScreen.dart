import 'single_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'UserModel.dart';
import 'MessageTextField.dart';

class ChatScreen extends StatelessWidget {
  final UserModel currentUser;
  final String friendId;
  final String friendName;
  final String friendImage;

  ChatScreen({Key? key, required this.currentUser, required this.friendId,required this.friendName,required this.friendImage});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(80),
            child: Image.network(friendImage,height: 35,),    
          ),
          SizedBox(width: 5,),
          Text(friendName,style: TextStyle(fontSize: 20),)
        ],),
      ),
      body: Column(
        children: [
          Expanded(child: 
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              )
            ),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('profileInfo').doc(currentUser.id).collection('messages').doc(friendId).collection('chats').orderBy('data',descending: true).snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if(snapshot.hasData){
                  if(snapshot.data.docs.length < 1){
                    return Center(
                      child: Text('Say Hi'),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    reverse: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      bool isMe = snapshot.data.docs[index]['senderId'] == currentUser.id;
                      return SingleMessage(snapshot.data.docs[index]['message'], isMe); 
                    },);
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          )),
          MessageTextField('', friendId)
        ],
      ), 
    );
  }
}

