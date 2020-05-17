import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/user.dart';
import 'package:com/pages/edit_profile.dart';
import 'package:com/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  final User profileId;
  ProfilePage({this.profileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentUserId = currentUser?.id;

  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController photoUrlController = TextEditingController();
  TextEditingController userTypeController = TextEditingController();

  //User user;

  bool isLoading = false;
  bool isLoadingInfo = false;

  logout() async {
    await googleSignIn.signOut();
    //Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }
  @override
  void dispose(){
    super.dispose();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.profileId.id).get();
    User user = User.formDocument(doc);
    displayNameController.text = user.fullName;
    bioController.text = user.bio;
    ageController.text = user.birthdate;
    phoneNumberController.text = user.phoneNumber;
    genderController.text = user.gender;
    emailController.text = user.email;
    userNameController.text = user.username;
    photoUrlController.text = user.photoUrl;
    userTypeController.text = user.userType;

    setState(() {
      isLoading = false;
    });
  }
  buildProfileInfo(){
    try {
      return FutureBuilder(

        future: userRef.document(widget.profileId.id).get(),
        builder: (context, snapshot) {

            return Container(
//              width: 250,
              height: 150,
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            );

        },

      );
    }catch(err){
      print(err);
    }
  }

  buildProfileHeader() {
    try {
      return FutureBuilder(
          future: userRef.document(widget.profileId.id).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                height: 150.0,
                alignment: Alignment.center,
                //padding: EdgeInsets.only(top: 10.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              );
            }
            User user2 = User.formDocument(snapshot.data);

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(user2.photoUrl),
                          backgroundColor: Colors.white,
                          radius: 50.0,
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 30.0),
                            child: Text(
//                        '${displayNameController.text}',
                              '${user2.fullName}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
//                        '(${userTypeController.text})',
                            '(${user2.userType})',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Row(
                            children: <Widget>[
                              Container(
                                width: 250.0,
                                height: 90.0,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blueAccent),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 25.0,top: 2.0),
                                  child: Text(
//                        '(${userTypeController.text})',
                                    '${user2.bio}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
//                Padding(
//                  padding: EdgeInsets.only(top: 15.0),
//                  child: TextFormField(
//                    //controller: bioController,
//                    maxLength: 100,
//                    maxLines: 3,
//                    enabled: false,
//                    initialValue: '${user2.bio}',
//                    style: TextStyle(fontWeight: FontWeight.bold),
//                    decoration: InputDecoration(
//                      prefixIcon: Icon(
//                        FontAwesomeIcons.infoCircle,
//                        color: Colors.blue,
//                      ),
//                      labelText: 'Bio',
//                      border: OutlineInputBorder(),
//                    ),
//                  ),
//                ),
                ],
              ),
            );
          });
    } catch (err) {
      print(err);
    }
  }


  @override
  Widget build(BuildContext context) {
    return
//      isLoading
//        ? Container(
//            alignment: Alignment.center,
//            //padding: EdgeInsets.only(top: 10.0),
//            child: CircularProgressIndicator(
//              valueColor: AlwaysStoppedAnimation(Colors.blue),
//            ),
//          )
//        :
        Scaffold(
      backgroundColor: Colors.blueAccent[200],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
            child: buildProfileHeader(),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(right: 10.0, left: 10.0),
              // padding: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 15.0
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Your Information:',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      TextFormField(
                        controller: userNameController,
                        enabled: false,
                        //initialValue: '${userIfno.username}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            FontAwesomeIcons.solidUserCircle,
                            color: Colors.blue,
                          ),
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: TextFormField(
                          controller: emailController,
                          enabled: false,
                          //initialValue: '${userIfno.email}',
                          //textAlign: TextAlign.center,
                          //readOnly: true,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.blue,
                            ),
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: TextFormField(
                          controller: ageController,
                          enabled: false,
//                          initialValue: '${userIfno.birthdate}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              FontAwesomeIcons.birthdayCake,
                              color: Colors.blue,
                            ),
                            labelText: 'Age',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: TextFormField(
                          controller: genderController,
                          enabled: false,
//                          initialValue: '${userIfno.gender}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            prefixIcon: currentUser.gender == "Male"
                                ? Icon(
                                    FontAwesomeIcons.mars,
                                    color: Colors.blue,
                                  )
                                : Icon(
                                    FontAwesomeIcons.venus,
                                    color: Colors.blue,
                                  ),
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: TextFormField(
                          controller: phoneNumberController,
                          enabled: false,
//                          initialValue: '${userIfno.phoneNumber}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              FontAwesomeIcons.phone,
                              color: Colors.blue,
                            ),
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1.8,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: FlatButton.icon(
                          splashColor: Colors.lightBlueAccent[100],
                          onPressed: () async => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfile(
                                        currentUserId: widget.profileId.id,
                                      ))),
                          icon: Icon(FontAwesomeIcons.userEdit,
                              color: Colors.black),
                          label: Text(
                            " Edit Profile",
                            style: TextStyle(
                                color: Colors.blueAccent, fontSize: 20.0),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1.8,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: FlatButton.icon(
                          splashColor: Colors.redAccent[100],
                          onPressed: () => logout(),
                          icon: Icon(Icons.cancel, color: Colors.red),
                          label: Text(
                            "Logout",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1.8,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
