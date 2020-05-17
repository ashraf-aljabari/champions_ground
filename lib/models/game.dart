import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/user.dart';
import 'package:com/pages/game_page.dart';
import 'package:com/pages/login_page.dart';
import 'package:com/pages/player_game_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:transparent_image/transparent_image.dart';



class Game extends StatefulWidget{
  final String p_name;
  final String ownerID;
  final String p_info;
  final String p_price;
  final String p_phoneNumber;
  final String p_location;
  final dynamic likes;
  final String p_lat;
  final String p_long;
  final String p_gender;
  final String p_numberOfPlayers;
  final String p_imageURL;
  final String gameId;
  final Timestamp created;
  final int bookedPlayers;

  Game({
    this.p_lat,
    this.p_long,
    this.likes,
    this.ownerID,
    this.p_gender,
    this.p_info,
    this.p_location,
    this.p_name,
    this.p_numberOfPlayers,
    this.p_phoneNumber,
    this.p_price,
    this.p_imageURL,
    this.gameId,
    this.created,
    this.bookedPlayers
});

  factory Game.formDocument(DocumentSnapshot doc){
    return Game(
      p_name: doc["p_name"],
      p_gender: doc["p_gender"],
      p_info: doc["p_info"],
      p_lat: doc["p_lat"],
      p_long: doc["p_long"],
      p_location: doc["p_location"],
      p_numberOfPlayers: doc["p_numberOfPlayers"],
      p_phoneNumber: doc["p_phoneNumber"],
      p_price: doc["p_price"],
      p_imageURL: doc["imageURL"],
      gameId: doc["gameId"],
      ownerID: doc["owner"],
      likes: doc["likes"],
      created: doc["created"],
      bookedPlayers: doc['bookedPlayers'],
    );
  }

  int getLikeCount(likes){
    if(likes == null){
      return 0;
    }

    int count = 0;

    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }
  @override
  _GameState createState() => _GameState(
    ownerId: this.ownerID,
    p_price: this.p_price,
    p_phoneNumber: this.p_phoneNumber,
    p_numberOfPlayers: this.p_numberOfPlayers,
    p_location: this.p_location,
    likes: this.likes,
    gameId: this.gameId,
    p_imageURL:this.p_imageURL,
    p_long: this.p_long,
    p_lat:this.p_lat,
    p_info: this.p_info,
    p_gender: this.p_gender,
    p_name:this.p_name,
    created: this.created,
    likeCount: getLikeCount(this.likes),
    bookedPlayers: this.bookedPlayers,

  );
}
class _GameState extends State<Game>{
  final String currentUserId = currentUser?.id;
  final String p_price;
  final String p_phoneNumber;
  final String p_numberOfPlayers;
  final String p_location;
  Map likes;
  final String gameId;
  final String p_imageURL;
  final String p_long;
  final String p_lat;
  final String p_info;
  final String p_gender;
  final String p_name;
  final String ownerId;
  final Timestamp created;
  final int bookedPlayers;
  bool isLiked;
  int likeCount;


  _GameState({
    this.p_name,
    this.p_gender,
    this.p_info,
    this.p_lat,
    this.p_price,
    this.p_imageURL,
    this.gameId,
    this.likes,
    this.p_location,
    this.p_numberOfPlayers,
    this.p_phoneNumber,
    this.p_long,
    this.ownerId,
    this.created,
    this.likeCount,
    this.bookedPlayers
  });



  buildGameHeader(){
    return FutureBuilder(
      future: userRef.document(ownerId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Container(
            height: 150.0,
            alignment: Alignment.center,
            //padding: EdgeInsets.only(top: 10.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          );
        }
        User user = User.formDocument(snapshot.data);
        bool isGameOwner = currentUserId == ownerId;
        return isGameOwner ? SizedBox() :Container(
          margin: EdgeInsets.only(left: 10.0,right: 10.0),
          color: Colors.white,
          child: ListTile(

            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            title: GestureDetector(
              onTap: () => print('showing profile'),
              child: Text(
                user.fullName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text(user.username,),
//            trailing: IconButton(
//                icon: Icon(Icons.more_vert),
//                onPressed: () => print('Delete game post'),
//            ),
          ),
        ) ;
      },
    );
  }

  handleLikes() async{
    bool _isLiked = likes[currentUserId] == false;
    print(gameId);
    print(ownerId);
    print(currentUserId);
    if(_isLiked){
      print(gameId);
      print(ownerId);
      print(currentUserId);
      await gameRef.document(ownerId)
          .collection('userGames')
          .document(gameId)
          .updateData({
        'likes.$currentUserId': false
//        'likes[$currentUserId]': true
          });
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    }else if (!_isLiked){
      print(gameId);
      print(ownerId);
      print(currentUserId);

      await gameRef
      .document(ownerId)
          .collection('userGames')
          .document(gameId)
          .updateData({
        'likes$currentUserId': true,
//        'likes': {'currentUserId' : 1234},
        //'likes': currentUserId
          });

      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
      });
    }
  }

  buildGamePost(){
    bool isGameOwner = currentUserId == ownerId;
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation:  5.0,
      child: Column(
        children: <Widget>[
          buildGameHeader(),
          isGameOwner ? SizedBox() :Divider(color: Colors.black,),
          ListTile(
            title: Text(p_name,style: TextStyle(
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
                Text(Moment.now().from(created
                    .toDate(),),
                ),
              ],
            ),
             trailing: isGameOwner? IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => print('Delete game post'),
            ): null,
          ),
          p_imageURL == null ? Container() : GestureDetector(
            onTap: (){
              if(currentUser.userType == 'Owner') {
                Navigator.push(context, MaterialPageRoute(builder:
                    (context) =>
                    GamePage(userId: ownerId, gameId: gameId,bookedPlayers: bookedPlayers,numberOfPlayers: p_numberOfPlayers,),),
                );
              }
              if(currentUser.userType == 'Player'){
                Navigator.push(context, MaterialPageRoute(builder:
                    (context) =>
                    PlayerGamePage(gameId: gameId, ownerId: ownerId,gamePhotoUrl: p_imageURL,gameName: p_name
                      ,lat: p_lat, long: p_long, adress: p_location,bookedPlayers:bookedPlayers,
                    ),
                ),
                );
              print('showing player post');
              }
            },
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: p_imageURL,
              fit: BoxFit.fill,
              width: 200,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Playground Information: $p_info'),
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
                  child: Text('Booking price: $p_price JD'),
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
                  child: Text('Playground Phone number: $p_phoneNumber'),
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
                  child: Text('Location: $p_location'),
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
                    "$likeCount Likes",
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  color: Colors.blue,
                  onPressed: handleLikes,
                  icon: Icon(
                    isLiked ? Icons.favorite: Icons.favorite_border,
                    color: Colors.red,
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

  Widget build (BuildContext context){
    isLiked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize:  MainAxisSize.min,
      children: <Widget>[

        buildGamePost(),
      ],
    );
  }
}