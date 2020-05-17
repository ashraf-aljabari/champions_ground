import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/game.dart';
import 'package:com/pages/login_page.dart';
import 'package:com/widgets/custom_image.dart';
import 'package:com/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class PlayerGamePage extends StatefulWidget {
  final String gameId;
  final String ownerId;
  final String gamePhotoUrl;
  final String gameName;
  final String lat;
  final String long;
  final String adress;
  final int bookedPlayers;
  PlayerGamePage({this.ownerId,this.gameId,this.gamePhotoUrl,this.gameName,this.long,this.lat,this.adress,this.bookedPlayers});

  @override
  _PlayerGamePageState createState() => _PlayerGamePageState();
}

class _PlayerGamePageState extends State<PlayerGamePage> {

  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  bool alreadyBooked = false;
  String bookButton;
  Color buttonColor;
  double lat;
  double long;
  int numOfPlayers;


  final Map<String,Marker> _marker = {};

  _onMapCreated(GoogleMapController controller) async{
    setState(() {
    final marker = Marker(
      markerId: MarkerId(widget.gameName),
      position: LatLng(double.parse(widget.lat),double.parse(widget.long)),
      infoWindow: InfoWindow(
        title: widget.gameName,
        snippet: widget.adress,
      ),

    );
    _marker[widget.gameName] = marker;
    });
  }

  @override
  void initState()  {
    super.initState();
    isAlreadyBooked();
    numOfPlayers = widget.bookedPlayers;
  }

  isAlreadyBooked()async{
    //when the player open the game it gets his bookings
    // information and check if this playground is already in the player bookings
    DocumentSnapshot snapshot = await playerBookedRef.document(currentUser.id)
        .collection('bookings')
        .document(widget.gameId).get();
    if(snapshot.exists){
      setState(() {
        alreadyBooked = true;
        bookButton = "Cancel Booking";
        buttonColor = Colors.red;
      });
    }else{
      setState(() {
        alreadyBooked = false;
        bookButton = "Book The Game";
        buttonColor = Colors.blueAccent;
      });
    }
  }

  void launchCaller(int number)async{

    var url = "tel:${'+962'+number.toString()}";
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'cant call number';
    }
  }
  void launchMapsUrl(String lat, String long)   async {

    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  booking()async{
    //to check if the game is already booked for the user or not
    if(alreadyBooked){
      await ownerBookedRef.document(widget.ownerId)
          .collection('bookItems')
          .document(currentUser.id).delete();

      await playerBookedRef.document(currentUser.id)
          .collection('bookings')
          .document(widget.gameId).delete();
      setState(() {
        alreadyBooked = false;
        bookButton = "Book The Game";
        buttonColor = Colors.blueAccent;
        numOfPlayers--;
      });
      await allGamesRef.document(widget.gameId).updateData({
        "bookedPlayers": numOfPlayers
      });
      await gameRef.document(widget.ownerId).collection('userGames').document(widget.gameId).updateData({
        "bookedPlayers": numOfPlayers
      });
    }else {
      //to add booking information to player & owner
      await ownerBookedRef.document(widget.ownerId)
          .collection('bookItems')
          .document(currentUser.id)
          .setData({
//      "ownerId": widget.ownerId,
        "timestamp": timeStamp,
        "type": "book",
        "playerId": currentUser.id,
        "playerName": currentUser.fullName,
        "userProfileImage": currentUser.photoUrl,
        "gameId": widget.gameId,
        "gamePhotoUrl": widget.gamePhotoUrl,
        "gameName": widget.gameName,
        "ownerId": widget.ownerId,
        "playerPhonenumber": currentUser.phoneNumber
      });

      await playerBookedRef.document(currentUser.id)
          .collection('bookings')
          .document(widget.gameId).setData({
        "ownerId": widget.ownerId,
        "timestamp": timeStamp,
        "type": "booked",
//      "playerId": currentUser.id,
        "playerName": currentUser.fullName,
        "userProfileImage": currentUser.photoUrl,
        "gameName": widget.gameName,
        "gameId": widget.gameId,
        "gamePhotoUrl": widget.gamePhotoUrl
      });

      setState(() {
        numOfPlayers++;
      });
      //to update the game bookings information
      await allGamesRef.document(widget.gameId).updateData({
        "bookedPlayers": numOfPlayers
      });
      await gameRef.document(widget.ownerId).collection('userGames').document(widget.gameId).updateData({
        "bookedPlayers": numOfPlayers
      });

      Timer(Duration(seconds: 1), () {
        _key.currentState.showSnackBar(
            SnackBar(content: Text('booking complete!'),));
      });
      setState(() {
        alreadyBooked = true;
        bookButton = "Cancel Booking";
        buttonColor = Colors.red;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: gameRef.document(widget.ownerId).collection('userGames')
          .document(widget.gameId).get(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        Game game = Game.formDocument(snapshot.data);

        return Center(
          child: Scaffold(
            key: _key,
            appBar: AppBar(
              title: Text('${game.p_name}'),
            ),
            body: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0,bottom: 10.0),
                  child: Text('${game.p_name}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.black,
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
//                launchCaller(int.parse(game.p_phoneNumber))
                GestureDetector(
                  onTap: ()=> launchCaller(int.parse(game.p_phoneNumber)),
                  child: Text('${game.p_phoneNumber}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.blue,
                      decoration: TextDecoration.underline
                    ),
                  ),
                ),
                Divider(thickness: 1,),
                RichText(
                  text: TextSpan(
                      text: 'playground information:',
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                      children: <TextSpan>[
                        TextSpan(text: '${game.p_info}', style:
                        TextStyle(fontSize: 25.0,color: Colors.red,
                            fontWeight: FontWeight.normal),),
                      ]
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Price:',
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                    children: <TextSpan>[
                      TextSpan(text: '${game.p_price}', style:
                      TextStyle(fontSize: 25.0,color: Colors.red,
                          fontWeight: FontWeight.normal),),
                      ]
                  ),
                ),
                RichText(
                  text: TextSpan(
                      text: 'Location:',
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                      children: <TextSpan>[
                        TextSpan(text: '${game.p_location}', style:
                        TextStyle(fontSize: 25.0,color: Colors.red,
                            fontWeight: FontWeight.normal),),
                      ]
                  ),
                ),
                RichText(
                  text: TextSpan(
                      text: 'Gender:',
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                      children: <TextSpan>[
                        TextSpan(text: '${game.p_gender}', style:
                        TextStyle(fontSize: 20.0,color: Colors.red,
                            fontWeight: FontWeight.normal),),
                      ]
                  ),
                ),
                RichText(
                  text: TextSpan(
                      text: 'number of players:',
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                      children: <TextSpan>[
                        TextSpan(text:  '$numOfPlayers/${game.p_numberOfPlayers}', style:
                        TextStyle(fontSize: 20.0,color: Colors.red,
                            fontWeight: FontWeight.normal),),
                      ]
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: GestureDetector(
                    onTap: () =>launchMapsUrl(game.p_lat,game.p_long),
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
                         onMapCreated: _onMapCreated,
                         markers: _marker.values.toSet(),
                         initialCameraPosition: CameraPosition(
                           target: LatLng(double.parse(game.p_lat),double.parse(game.p_long)),
                           zoom: 14,
                         ),
                       ),
                     ),
                      ),
                  ),
                ),
                RaisedButton(
                  elevation: 0.8,
                  onPressed: () => booking(),
                  color: buttonColor,
                  child: alreadyBooked ? Text('$bookButton',style: TextStyle(color: Colors.white,fontSize: 20.0),)
                      : Text('$bookButton',style: TextStyle(color: Colors.white,fontSize: 20.0),),
                ),
              ],
            ),

          ),
        );
      },
    );
  }
}
