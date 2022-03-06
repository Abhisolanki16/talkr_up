import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:talkr_demo/Services/AuthMethods.dart';
import 'package:talkr_demo/Services/FirestoreMethods.dart';
import 'package:talkr_demo/Services/user.dart';
import 'package:talkr_demo/Services/user_provider.dart';
import 'package:talkr_demo/Services/utils.dart';
import 'package:talkr_demo/screens/feed_screen.dart';


class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;

  Uint8List? _file;

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    
    return _file == null
        ? Container(
          color: Colors.black,
          child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.upload,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => _selectImage(context),
                  ),
          ),
        )
     : Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: clearImage),
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          "Post to",style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: Text("Post",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18)),
              onPressed: () => postImage(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
             )
        ],
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                const Divider(),
          Row(
            mainAxisAlignment : MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(userProvider.getUser.photoUrl)
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.55,
                child:  TextField(
                  controller: _descriptionController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Write a caption ...',
                    hintStyle: TextStyle(color: Colors.white38,),
                    border: InputBorder.none  
                  ),
                  maxLines: 2,
                ),
                ),
                SizedBox(
                  height: 60,
                  width: 50,
                  child: Container(
                      decoration: BoxDecoration(
                        image : DecorationImage(
                          image: MemoryImage(_file!),
                          fit: BoxFit.fill,
                        )   
                      ),
                    )
                  ,),
                  const Divider(),
          ],),             
        ],),
             
    );
  }
}


