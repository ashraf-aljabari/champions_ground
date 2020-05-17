import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/game.dart';
import 'package:com/models/user.dart';
import 'package:com/pages/login_page.dart';
import 'package:com/pages/upload_playground_page.dart';
import 'package:com/widgets/game_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:transparent_image/transparent_image.dart';

//final CollectionReference userRef = Firestore.instance.collection('users');
//final GoogleSignIn googleSignIn = GoogleSignIn();

class MyHomePage extends StatefulWidget {
  final String profileId;
  MyHomePage({this.profileId});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Firestore _firestore = Firestore.instance;
  final databaseRef = Firestore.instance;
  String image;
  Map list;

  Future getPlaygroundsFuture;

  List<Widget> playgrounds = [];
  List<DocumentSnapshot> playgroundDoc = [];

  String gamesOrientation = "grid";
  List<Game> games = [];
  bool isLoading = true;

  DocumentSnapshot lastDoc;

  Map map;
  bool isTrue = true;




  Future getPlayground()async{
    //playgrounds = [];

    Query query = _firestore.collection('games')
        .document(googleSignIn.currentUser.id).collection('userGames')
        .orderBy("created",descending: true).limit(10);
    QuerySnapshot querySnapshot = await query.getDocuments();

    playgroundDoc = querySnapshot.documents;

    print('before the loop');
    for (var i=0; i< playgroundDoc.length; i++) {
      Widget widget = makeCard(playgroundDoc[i]);
      print(playgroundDoc[0].data["p_name"]);
      print(widget.toString());
      playgrounds.add(widget);
      print('inside');
      isTrue = false;
    }

    print('after');
    return playgroundDoc;

  }

//  getData()async{
//    DocumentSnapshot snapshot;
//    snapshot = await databaseRef.collection("users").document(googleSignIn.currentUser.id).get();
//    print(snapshot);
//    list = snapshot.data;
//    print(list["photoUrl"]);
//    User.formDocument(snapshot);
//    User user;
//    image =user.photoUrl;
//    print(googleSignIn.currentUser.id);
//    print(list["gender"]);
//  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    getOwnerGames();
    //getData();
//    getPlayground();

//
    //googleSignIn.currentUser.id;
   //getUser();
  }

//  getUser()async{
//    final doc = await userRef.document("106152792049148008109").get();
//    print('${doc.data}');
//    User.formDocument(doc);
//  }
//  usersRef.document(currentUserId).get()
//  User user = User.formDocument(snapshot.data);

//  profile() {
//
//   return FutureBuilder(
//     //future: usersRef.document(widget.profileId.id).get(),
//     builder: (context,snapshot){
////       if(!snapshot.hasData){
////         return CircularProgressIndicator();
////       }
////      User user = User.formDocument(snapshot.data);
//       return Column(
//         children: <Widget>[
//           CircleAvatar(
//             radius: 50.0,
//             backgroundColor: Colors.white,
//             backgroundImage: CachedNetworkImageProvider(list["photoUrl"]),
//           ),
////           SizedBox(
////             width: 15,
////             height: 5,
////           ),
//           Text(list["displayName"],
//             style: TextStyle(
//                 fontSize: 15.0,
//                 color: Colors.white
//             ),
//           ),
//         ],
//       );
//     },
//   );
//  }


  getItems(){
    List<Widget> items = [];

    Widget separator = Container(
      padding: EdgeInsets.all(10),
      child: Text('Added playgrounds', textAlign: TextAlign.left,
      style: TextStyle(
        color: Colors.black54,
      ),
      ),
    );

    items.add(separator);

    Widget playgroundsList = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: playgrounds,
    );
    items.add(playgroundsList);
    return items;
  }

  buildProfile(){
    if(isLoading){
      return Container(
        height: 150.0,
        alignment: Alignment.center,
        //padding: EdgeInsets.only(top: 10.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.black),
        ),
      );
    }else if (games.isEmpty){
      return Container();
    }else if (gamesOrientation == "grid"){
      List<GridTile> gridTile = [];

      games.forEach((games){
        gridTile.add(GridTile(child: GameTile(game: games,),));
      });
      return GridView.count(crossAxisCount: 3,
      childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTile,
      );
    }else if(gamesOrientation == "list"){
      return Column(children: games,);
    }
  }

  setGameOrientation(String gameOrientation){
    setState(() {
      this.gamesOrientation = gameOrientation;
    });
  }

  buildGameOrientationButtons(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setGameOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: gamesOrientation == 'grid'? Theme.of(context).primaryColor: Colors.grey,
        ),
        IconButton(
          onPressed: () => setGameOrientation("list"),
          icon: Icon(Icons.list),
          color: gamesOrientation == 'list'? Theme.of(context).primaryColor: Colors.grey,
        ),
      ],
    );
  }
  
  getOwnerGames() async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await gameRef
    .document(widget.profileId)
    .collection('userGames')
    .orderBy("created",descending: true)
    .getDocuments();

    setState(() {
      isLoading =  false;
      games = snapshot.documents.map((doc)=>Game.formDocument(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Home Page'),
      ),
    body: Column(
       children: <Widget>[
         Container(
           color: Colors.white,
           child: buildGameOrientationButtons(),
         ),
         Divider(color: Colors.white,),
         Expanded(
           child:
           ListView(
             children: <Widget>[
               Container(
                 padding: EdgeInsets.only(bottom: 10.0, left: 10.0),
                 child: Text('Added playgrounds:', textAlign: TextAlign.left,
                   style: TextStyle(
                       color: Colors.black,
                       fontSize: 15.0,
                       fontWeight: FontWeight.bold
                   ),
                 ),
               ),
               buildProfile(),
             ],
           ),

         ),

       ],
    ),
    );
  }
}
//
//Column(
//children: playgrounds,
//),

Widget makeCard(DocumentSnapshot playgroundDoc) {
  return Card(
    margin: EdgeInsets.all(8.0),
    elevation:  5.0,
    child: Column(
      children: <Widget>[
        ListTile(
          title: Text(playgroundDoc.data["p_name"],style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),),
          subtitle: Row(
            mainAxisAlignment:  MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.watch_later,size: 14.0,),
              SizedBox(
                width: 4.0,
              ),
              Text(Moment.now().from((playgroundDoc.data["created"]as Timestamp)
                  .toDate(),),
              ),
            ],
          ),
        ),
        playgroundDoc.data["imageURL"] == null ? Container() : FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: playgroundDoc.data["imageURL"],
          fit: BoxFit.fill,
          width: 200,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Playground Information: ${playgroundDoc.data["p_info"]}'),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Booking price: ${playgroundDoc.data["p_price"]} JD'),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Playground Phone number: ${playgroundDoc.data["p_phoneNumber"]}'),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Location: ${playgroundDoc.data["p_location"]}'),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 1,
          child: Container(
            color: Colors.black,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
//            width: 200.0,
//            height: 100.0,
              //alignment: Alignment.center,
              child: RaisedButton.icon(
                label: Text(
                  "Likes",
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.blue,
                onPressed: null,
                icon: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
//            width: 200.0,
//            height: 100.0,
              //alignment: Alignment.center,
              child: RaisedButton.icon(
                label: Text(
                  "Comments",
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.blue,
                onPressed: null,
                icon: Icon(
                  Icons.comment,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
//            width: 200.0,
//            height: 100.0,
              //alignment: Alignment.center,
              child: RaisedButton.icon(
                label: Text(
                  "Share",
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.blue,
                onPressed: null,
                icon: Icon(
                  Icons.share,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


//drawer: Drawer(
//child: ListView(
//padding: EdgeInsets.zero,
//children: <Widget>[
//DrawerHeader(
//child: Column(
//children: <Widget>[
//profile(),
//],
//),
//decoration: BoxDecoration(
//color: Colors.blue,
//),
//),
//ListTile(
//title: Text('Profile'),
//trailing: Icon(Icons.account_circle),
//onTap: (){
//// getUser();
//},
//),
//ListTile(
//title: Text('Bookings'),
//trailing: Icon(Icons.book),
//onTap: (){
//Navigator.pop(context);
//},
//),
//ListTile(
//title: Text('Sign out'),
//trailing: Icon(Icons.exit_to_app),
//onTap: (){
//logout();
//},
//),
//],
//),
//),
////      floatingActionButton: FloatingActionButton(
////        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadPage(currentUser))),
////        backgroundColor: Theme.of(context).primaryColor,
////        child: Icon(Icons.add,color: Colors.white,size: 30.0,),
////
////      ),