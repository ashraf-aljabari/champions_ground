
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/game.dart';
import 'package:com/pages/game_page.dart';
import 'package:com/pages/login_page.dart';
import 'package:com/pages/player_game_page.dart';
import 'package:com/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:simple_moment/simple_moment.dart';

class BookingsPage extends StatefulWidget {
  final String currentUserId;

  BookingsPage({this.currentUserId});
  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {

  List<BookedGamesItem> gameItems = [];

  getBookedGames() async{
    QuerySnapshot snapshot = await playerBookedRef
        .document(widget.currentUserId)
        .collection('bookings')
        .orderBy('timestamp',descending: true)
        .limit(50)
        .getDocuments();


    snapshot.documents.forEach((doc){
      gameItems.add(BookedGamesItem.formDocument(doc));
    });

//    print(gameItems);
    return gameItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        leading: Icon(Icons.favorite),
        title: Text('Booked Games'),
      ),
      body: Container(
        child: FutureBuilder(
          future: getBookedGames(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 10.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ),
              );
            }
            return ListView(
              children: gameItems,
            );
          },
        ),
      ),
    );
  }
}

Widget mediaPreview;

class BookedGamesItem extends StatelessWidget {
    final String ownerId;
  final Timestamp timestamp;
  final String type;
  final String playerName;
  final String userProfileImage;
  final String gameName;
  final String gameId;
  final String gamePhotoUrl;

  BookedGamesItem({
   this.gameName,
   this.gamePhotoUrl,
   this.gameId,
   this.ownerId,
   this.timestamp,
   this.type,
   this.playerName,
   this.userProfileImage
});

      factory BookedGamesItem.formDocument(DocumentSnapshot doc){
    return BookedGamesItem(
      ownerId: doc['ownerId'],
      gameName: doc['gameName'],
      gamePhotoUrl: doc['gamePhotoUrl'],
      gameId: doc['gameId'],
      timestamp: doc['timestamp'],
      type: doc['type'],
      playerName: doc['playerName'],
      userProfileImage: doc['userProfileImage'],
    );
  }
  int number;


  showGame(context)async{
    DocumentSnapshot doc = await gameRef.document(ownerId).collection('userGames')
        .document(gameId).get();
    Game game = Game.formDocument(doc);
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => PlayerGamePage(
            gameId: gameId,
            ownerId: ownerId,
            gameName: gameName,
            gamePhotoUrl: gamePhotoUrl,
            bookedPlayers: game.bookedPlayers,
            adress: game.p_location,
            long: game.p_long,
            lat: game.p_lat,

          ),
        ));
  }

      configureMediaPreview(context){
    mediaPreview = GestureDetector(
      onTap: () => showGame(context),
      child: Container(
        height: 50,
        width: 50,
        child: AspectRatio(
          aspectRatio: 16/9,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(gamePhotoUrl),
              )
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
        configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => print('show profile'),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Booked Game Name:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text: ' $gameName'
                  ),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
          ),
          subtitle: Row(
            mainAxisAlignment:  MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.watch_later,size: 14.0,),
              SizedBox(
                width: 4.0,
              ),
              Text(Moment.now().from(timestamp.toDate(),),
              ),
            ],
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}



