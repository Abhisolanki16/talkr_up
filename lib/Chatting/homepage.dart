import 'SearchScreen.dart';
import 'UserModel.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  UserModel user;
  HomeScreen(this.user);
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchScreen(widget.user)));
          
        },
      ),
    );
  }
}