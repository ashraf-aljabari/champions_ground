import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/user.dart';
import 'package:com/pages/bookings_page.dart';
import 'package:com/pages/create_account.dart';
import 'package:com/pages/home_page.dart';
import 'package:com/pages/notifications_page.dart';
import 'package:com/pages/player_home_page.dart';
import 'package:com/pages/profile_page.dart';
import 'package:com/pages/search.dart';
import 'package:com/pages/upload_playground_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';



final CollectionReference userRef = Firestore.instance.collection('users');
final CollectionReference gameRef = Firestore.instance.collection('games');
final CollectionReference allGamesRef = Firestore.instance.collection('allGames');
final CollectionReference ownerBookedRef = Firestore.instance.collection('ownerBookedGames');
final CollectionReference playerBookedRef = Firestore.instance.collection('playerBookedGames');

final StorageReference storageRef = FirebaseStorage.instance.ref();
final GoogleSignIn googleSignIn = GoogleSignIn();
final DateTime timeStamp = DateTime.now();
bool isAuth = false;
bool currentUserType= false;
User currentUser;

class LoginPage extends StatefulWidget {


  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {

 // GoogleSignIn googleSignIn = GoogleSignIn();

  PageController pageController;
  int pageIndex = 0;


  @override
  initState(){
    super.initState();
    pageController = PageController();
    // this detects when user sign's in
    googleSignIn.onCurrentUserChanged.listen((account){
      handleSignIn(account);
    },onError: (error){
      print('Error signing in: $error');
    });



    // re Auth user when the app is oppened again if he's signed in
    googleSignIn.signInSilently(suppressErrors: false)
        .then((account){
      handleSignIn(account);
    }).catchError((error){
      print('Error signing in: $error');
    });

  }
  gettingUserType(){

  }
  @override
  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  handleSignIn(GoogleSignInAccount account)async{
    if(account != null){
      await createUserInFirestore();
       setState(() {
        isAuth = true;
//        if(currentUser.userType != null) {
//          if (currentUser.userType == 'Owner') {
//            setState(() {
//              currentUserType = true;
//            });
//          } else {
//            setState(() {
//              currentUserType = false;
//            });
//          }
//        }
      });

    }else{
      setState(() {
        isAuth = false;
      });
    }
  }


  createUserInFirestore() async{
    // first step to check if our user exists in user collection in the database according to their id
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();
    //currentUser = User.formDocument(doc);
    //print(currentUser.fullName);

    if(!doc.exists){
         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> CreateAccount()));
        //widget.currentUser = currentUser;
    }
    if(doc.exists){
       currentUser =  User.formDocument(doc);
//      if(currentUser.userType != null) {
        if (currentUser.userType == 'Owner') {
          setState(() {
            currentUserType = true;
          });
        } else {
          setState(() {
            currentUserType = false;
          });
        }
//      }
      return;
    }
  }

  login(){
    googleSignIn.signIn();
  }

  onPageChanged(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex){
    pageController.animateToPage(
        pageIndex,
        duration: Duration(microseconds: 300),
        curve: Curves.bounceInOut
    );
  }

  Scaffold buildAuthScreen(){
    return currentUserType ?Scaffold(
      body: PageView(
//        physics: ,
        children: <Widget>[
//          RaisedButton(
//            child: Text('hi'),
//            onPressed: null,
//          ),

          MyHomePage(profileId: currentUser?.id,),
          NotificationsPage(currentUserId: currentUser.id,),
          UploadPage(currentUserId: currentUser,),
          Search(),
          ProfilePage(profileId: currentUser,),
         // UploadPage(currentUser),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items:[
          BottomNavigationBarItem(icon: Icon(Icons.filter_list),),
          BottomNavigationBarItem(icon: Icon(Icons.notifications),),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline),),
          BottomNavigationBarItem(icon: Icon(Icons.search),),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle),),

        ]
      ),
    ):

    Scaffold(
      body: PageView(
        children: <Widget>[
//          RaisedButton(
//            child: Text('hi'),
//            onPressed: null,
//          ),
          PlayerHomePage(),
          BookingsPage(currentUserId: currentUser.id,),
          Search(),
          ProfilePage(profileId: currentUser,),
          // UploadPage(currentUser),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items:[
            BottomNavigationBarItem(icon: Icon(Icons.home),),
            BottomNavigationBarItem(icon: Icon(Icons.favorite,),),
            BottomNavigationBarItem(icon: Icon(Icons.search),),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle),),

          ]
      ),
    );
  }

 buildUnAuthScreen(){
   return Scaffold(
     body: Container(
       decoration: BoxDecoration(
         gradient: LinearGradient(
             begin: Alignment.topRight,
             end: Alignment.bottomLeft,
             colors:[
               Theme.of(context).primaryColor,
               Theme.of(context).accentColor,
             ]
         ),
       ),
       alignment: Alignment.center,
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: <Widget>[
           Container(
             height: 180.0,
             padding: EdgeInsets.only(top: 25.0),
             //width: MediaQuery.of(context).size.width * 0.8,
             child: AspectRatio(
               aspectRatio: 1 / 1,
               child: Container(
                 decoration: BoxDecoration(
                   // color: Colors.black,
                   shape: BoxShape.circle,
                   image: DecorationImage(
                     fit: BoxFit.cover,
                     image:  AssetImage('assets/images/logo.jpg'),
                   ),
                 ),
               ),
             ),
           ),
//           CircleAvatar(
//             backgroundColor: Colors.white,
//             radius: 60.0,
//
//             child:
//               Image.asset('assets/images/logo.png'),
////             Icon(
////               Icons.golf_course,
////               color: Colors.black,
////               size: 70.0,
////             ),
//           ),
           SizedBox(
             height: 20.0,
           ),
           Text('Champion\'s Ground',
             style: TextStyle(
                 fontFamily: "Signatra",
                 fontSize: 55.0,
                 color: Colors.white
             ),
           ),
           SizedBox(
             height: 20.0,
           ),
           GestureDetector(
             onTap: login,
             child: Container(
               width: 260.0,
               height: 60.0,
               decoration: BoxDecoration(
                   image: DecorationImage(
                     image: AssetImage('assets/images/google_signin_button.png'),
                     fit: BoxFit.cover,
                   )
               ),
             ),
           ),
         ],
       ),
     ),
   );
 }
 test()async{
    await Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateAccount(),));
 }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
