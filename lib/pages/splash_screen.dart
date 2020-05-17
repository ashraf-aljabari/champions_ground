import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/user.dart';
import 'package:com/pages/home_page.dart';
import 'package:com/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //GoogleSignInAccount user = googleSignIn.currentUser;

  @override
  void initState() {
    super.initState();
   // Timer(Duration(seconds: 5), checkForLoginUser(user));
  }
  checkForLoginUser(GoogleSignInAccount account) {
//    DocumentSnapshot doc =  usersRef.document(user.id).get();
//    doc = usersRef.document(user.id).get();
//    googleSignIn.signInSilently(suppressErrors: false)
//    .then((account){
//      if (account != null) {
//        //currentUser = User.formDocument(doc);
////        Navigator.push(
////            context, MaterialPageRoute(builder: (context) => MyHomePage(profileId: currentUser?.id,)));
//      }
//      }).catchError((error) {
//        print('this error happened! $error');
//      Navigator.push(
//          context, MaterialPageRoute(builder: (context) => LoginPage()));
//    });
//
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
               // color: Colors.white
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor,
                ]
              )
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 60.0,
                        child: Icon(
                          Icons.golf_course,
                          color: Colors.black,
                          size: 70.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TypewriterAnimatedTextKit(
                            text: ['Chamions Ground'],
                            textStyle: TextStyle(
                              fontSize: 50.0,
                              color: Colors.white,
                              fontFamily: 'Signatra',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10.0)
                    ),
                    Text('Online sport\'s \n booking app',
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
