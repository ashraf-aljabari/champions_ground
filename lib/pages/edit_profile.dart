import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/user.dart';
import 'package:com/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool displayNameValid = true;
  bool bioValid = true;


  bool isLoading = false;
  User user;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  void dispose(){
    super.dispose();
  }

  getUser()async{
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.currentUserId).get();
    user = User.formDocument(doc);
    displayNameController.text = user.fullName;
    bioController.text = user.bio;

    setState(() {
      isLoading = false;
    });
  }

  Column buildProfileInfo(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: TextFormField(
            controller: displayNameController,
            style: TextStyle(
//                fontWeight: FontWeight.bold
            ),
            decoration: InputDecoration(
              hintText: "Update Display Name",
              errorText: displayNameValid? null : "Display Name too short",
              prefixIcon: Icon(FontAwesomeIcons.font,color: Colors.blue,),
              labelText: 'Display Name',
              border: OutlineInputBorder(
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: TextFormField(
            maxLines: 3,
            maxLength: 100,
            controller: bioController,
            style: TextStyle(
//                fontWeight: FontWeight.bold
            ),
            decoration: InputDecoration(
              hintText: "Update Your bio",
              errorText: bioValid? null : "Bio is too long!",
              prefixIcon: Icon(FontAwesomeIcons.infoCircle,color: Colors.blue,),
              labelText: 'Bio',
              border: OutlineInputBorder(
              ),
            ),
          ),
        ),
      ],
    );
  }

  updateProfileData(){
    setState(() {
      displayNameController.text.trim().length < 3 ||
      displayNameController.text.isEmpty ?
          displayNameValid = false :
          displayNameValid = true;
      bioController.text.trim().length >100 ?
          bioValid = false :
          bioValid = true;
    });

    if(displayNameValid && bioValid){
      userRef.document(widget.currentUserId).updateData({
        "displayName": displayNameController.text,
        "bio": bioController.text,
      });
      SnackBar snackBar = SnackBar(content: Text('Profile updated!'),);
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
      body: isLoading ?
          Container(
            alignment: Alignment.center,
              //padding: EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.blue),
              ),
          ):
      ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    top: 16.0,
                    bottom: 8.0,
                  ),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage:
                    CachedNetworkImageProvider(currentUser.photoUrl),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      buildProfileInfo(),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: ()=> updateProfileData(),
                  child: Text(
                    "Update Profile",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
