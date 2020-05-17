import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/game.dart';
import 'package:com/pages/game_page.dart';
import 'package:com/pages/login_page.dart';
import 'package:com/widgets/progress.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:simple_moment/simple_moment.dart';

class NotificationsPage extends StatefulWidget {
  final String currentUserId;

  NotificationsPage({this.currentUserId});
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  List<BookedGamesItem> notifList = [];


  @override
  void initState(){
    super.initState();
    final fbm = FirebaseMessaging();
    fbm.configure(
      onMessage: (msg) {
        print(msg);
        return;
      },
      onLaunch: (msg){
        print(msg);
        return;
      },
      onResume: (msg){
        print(msg);
        return;
      }
    );
    fbm.subscribeToTopic('notifying');

  }

  getBookedGames() async{
    QuerySnapshot snapshot = await ownerBookedRef
        .document(widget.currentUserId)
        .collection('bookItems')
        .orderBy('timestamp',descending: true)
        .limit(50)
        .getDocuments();


    snapshot.documents.forEach((doc){
      notifList.add(BookedGamesItem.formDocument(doc));
    });

    return notifList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        leading: Icon(Icons.notifications_active),
        title: Text('Notifications'),
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
              children: notifList,
            );
          },
        ),
      ),
    );
  }
}

Widget mediaPreview;

class BookedGamesItem extends StatelessWidget {
  final String gameId;
  final String gamePhotoUrl;
  final String playerName;
  final String playerId;
  final Timestamp timestamp;
  final String type;
  final String userProfileImage;
  final String gameName;
  final String ownerId;

  BookedGamesItem({
    this.gameName,
    this.gamePhotoUrl,
    this.gameId,
    this.playerId,
    this.timestamp,
    this.type,
    this.playerName,
    this.userProfileImage,
    this.ownerId
  });

  factory BookedGamesItem.formDocument(DocumentSnapshot doc){
    return BookedGamesItem(
      playerId: doc['playerId'],
      gameName: doc['gameName'],
      gamePhotoUrl: doc['gamePhotoUrl'],
      gameId: doc['gameId'],
      timestamp: doc['timestamp'],
      type: doc['type'],
      playerName: doc['playerName'],
      userProfileImage: doc['userProfileImage'],
      ownerId: doc['ownerId'],
    );
  }
  showGame(context)async{
    DocumentSnapshot doc = await gameRef.document(ownerId).collection('userGames')
        .document(gameId).get();
    Game game = Game.formDocument(doc);
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => GamePage(
        gameId: gameId,
        userId: ownerId,
        bookedPlayers: game.bookedPlayers,
        numberOfPlayers: game.p_numberOfPlayers,
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
                    text: '$playerName Booked:',
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
            backgroundImage: CachedNetworkImageProvider(userProfileImage),
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