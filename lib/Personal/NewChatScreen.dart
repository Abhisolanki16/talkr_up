import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewChatScreen extends StatelessWidget {

  final Map<String,dynamic> userMap;
  final String newChatRoomId; 
  NewChatScreen(this.newChatRoomId,this.userMap);

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void onSendMessage() async{

    if(_message.text.isNotEmpty) {
      Map<String,dynamic> messages = {
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "time": FieldValue.serverTimestamp(),

      
    };
    _message.clear();
    
    await _firestore
      .collection('chats')
      .doc(newChatRoomId)
      .collection('chats')
      .add(messages);
      
    }else{
      print('Enter some text');
    }
    
    
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(userMap['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
            height: size.height / 1.25,
            width: size.width,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
              .collection("chatRoom")
              .doc(newChatRoomId)
              .collection('chats')
              .orderBy('time',descending: false)
              .snapshots(),

              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(snapshot.data!= null){
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                      return messages(size,map);
                    },
                  );
                }else{
                  return Container();
                }
                
              },
            ),
          ),
          Container(
          height: size.height / 10,
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            height: size.height / 12,
            width: size.width / 1.1,
            child: Row(
              children: [
                Container(
                  height: size.height / 12,
                  width: size.width / 1.5,
                  child: TextField(
                    controller: _message,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), 
                      )
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    onSendMessage();
                  },)
              ],
            ),
      
          ),
        ),]),
      ),
    );
  }
  Widget messages(Size size,Map<String,dynamic> map){
    return Container(
      width: size.width,
      alignment: map['sendby'] == _auth.currentUser!.displayName
      ? Alignment.centerRight
      :Alignment.centerLeft,

      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        color: Colors.blue,
        child: Text(map['message'],style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),


      ),
    );
  }
}