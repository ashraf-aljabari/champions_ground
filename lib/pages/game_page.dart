import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/game.dart';
import 'package:com/models/user.dart';
import 'package:com/pages/login_page.dart';
import 'package:com/widgets/custom_image.dart';
import 'package:com/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:url_launcher/url_launcher.dart';

class GamePage extends StatefulWidget {
  final String userId;
  final String gameId;
  final int bookedPlayers;
  final String numberOfPlayers;

  GamePage({this.gameId, this.userId,this.bookedPlayers,this.numberOfPlayers});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  List<UserTile> users = [];

  final Map<String,Marker> _marker = {};

  getBookedUsers()async{
    QuerySnapshot snapshot = await ownerBookedRef.document(widget.userId)
        .collection('bookItems').orderBy('timestamp',descending: true).limit(50).getDocuments();
    snapshot.documents.forEach((doc){
      users.add(UserTile.formDocument(doc));
    });
    return users;
  }

  @override
  void initState(){
    super.initState();
    getBookedUsers();
  }


  Widget exTile(){

    return SingleChildScrollView(
      child: Card(
        child: ExpansionTile(
          leading: Icon(FontAwesomeIcons.users,color: Colors.blueAccent,),
          title: Text('Bookings',style: TextStyle(fontWeight: FontWeight.bold,),),
          subtitle: Text('${widget.bookedPlayers}/${widget.numberOfPlayers}'),
          children: users,
        ),
      ),
    );
  }

  Widget listData(){
    return FutureBuilder(
        future: gameRef.document(widget.userId).collection('userGames')
            .document(widget.gameId).get(),
        builder: (context,snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          Game game = Game.formDocument(snapshot.data);
          return SingleChildScrollView(
            child: Card(
              child: ExpansionTile(
                leading: Icon(FontAwesomeIcons.infoCircle,color: Colors.blueAccent,),
                title: Text('Game Information',style: TextStyle(fontWeight: FontWeight.bold,),),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.grey[50],
                      child: ListTile(
                        leading: Icon(FontAwesomeIcons.info,color: Colors.blueAccent),
                        title: Text('${game.p_info}'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.grey[50],
                      child: ListTile(
                        leading: Icon(FontAwesomeIcons.venusMars,color: Colors.blueAccent),
                        title: Text('${game.p_gender}'),
                      ),
                    ),
                  ),
//                  Padding(
//                    padding: const EdgeInsets.all(8.0),
//                    child: Container(
//                      color: Colors.blue[50],
//                      child: ListTile(
//                        leading: Icon(FontAwesomeIcons.locationArrow,color: Colors.blueAccent),
//                        title: Text('${game.p_location}'),
//                      ),
//                    ),
//                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.grey[50],
                      child: ExpansionTile(
                        leading: Icon(FontAwesomeIcons.mapMarked,color: Colors.blueAccent),
                        title: Text('${game.p_location}'),
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(20.0),
                            width: MediaQuery.of(context).size.width,
                            child: GestureDetector(
                              //onTap: () =>launchMapsUrl(game.p_lat,game.p_long),
                              child: Container(
                                padding: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 15.0, // has the effect of softening the shadow
                                      spreadRadius: 5.0, // has the effect of extending the shadow
                                      offset: Offset(
                                        7.0, // horizontal, move right 10
                                        7.0, // vertical, move down 10
                                      ),
                                    ),
                                  ],
                                  color: Colors.grey[300],
                                  border: Border.all(
                                      width: 3,
                                      color: Colors.blueAccent
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                height: 200.0,
                                width: 50.0,
                                child: AbsorbPointer(
                                  absorbing: true,
                                  child: GoogleMap(
                                    //onMapCreated: _onMapCreated,
//                                markers: _marker.values.toSet(),
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(double.parse(game.p_lat),double.parse(game.p_long)),
                                      zoom: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.grey[50],
                      child: ListTile(
                        leading: Icon(FontAwesomeIcons.dollarSign,color: Colors.blueAccent),
                        title: Text('${game.p_price}'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.grey[50],
                      child: ListTile(
                        leading: Icon(FontAwesomeIcons.phone,color: Colors.blueAccent),
                        title: Text('${game.p_phoneNumber}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
    );
  }

//  Column(
////              mainAxisAlignment: MainAxisAlignment.spaceAround,
//  children: <Widget>[Flexible(child: listData()),Flexible(child: exTile())],
//  ) ,

  @override
  Widget build(BuildContext context) {
    return Center(
          child: Scaffold(
            appBar: AppBar(
              title: Text('Game Information'),
            ),
            body: FutureBuilder(
              future: gameRef.document(widget.userId).collection('userGames')
                  .document(widget.gameId).get(),
              builder: (context,snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                }
                Game game = Game.formDocument(snapshot.data);
                return ListView(
//            shrinkWrap: true,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.blue[50],
                        child: ListTile(
                          leading: Icon(FontAwesomeIcons.bold),
                          title: Text('${game.p_name}'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: cachedNetworkImage(game.p_imageURL),
                            width: 250,
                            height: 250,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        listData(),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        exTile(),
                      ],
                    ),

                  ],
                );
              },
            ),
          ),
        );

  }
}


class UserTile extends StatelessWidget {
  final String userId;
  final Timestamp time;

  UserTile({this.userId,this.time});
  factory UserTile.formDocument(DocumentSnapshot doc){
    return UserTile(
      userId: doc['playerId'],
      time: doc['timestamp'],
    );
  }

  void launchCaller(int number)async{

    var url = "tel:${'+962'+number.toString()}";
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'cant call number';
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:  userRef.document(userId).get(),
      builder: (context,snapshot){
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.formDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(2.0),
          child: Container(
            color: Colors.white54,
            child: ListTile(
              leading:  CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
              ),
              title: RichText(
                text: TextSpan(
                    text: '${user.fullName}    ',
                    style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),
                    children: <TextSpan>[

                      TextSpan(text: '${user.phoneNumber}', style:
                      TextStyle(color: Colors.blueAccent,
                          fontWeight: FontWeight.normal,decoration: TextDecoration.underline),

                      ),
                    ]
                ),
              ),//Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              subtitle: Row(
                mainAxisAlignment:  MainAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.watch_later,size: 14.0,),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(Moment.now().from(time.toDate(),),
                  ),
                ],
              ),
              trailing: GestureDetector(
                  onTap: () => launchCaller(int.parse(user.phoneNumber)),
                  child: Icon(FontAwesomeIcons.phoneAlt,color: Colors.blueAccent,),),
            ),
          ),
        );
      },
    );
  }
}
