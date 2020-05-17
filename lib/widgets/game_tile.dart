import 'package:com/models/game.dart';
import 'package:com/pages/game_page.dart';
import 'package:com/pages/login_page.dart';
import 'package:com/pages/maps.dart';
import 'package:com/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class GameTile extends StatelessWidget {
  final Game game;

  GameTile({this.game});

  showGame(context){
      Navigator.push(context, MaterialPageRoute(builder:
          (context) =>
          GamePage(userId: game.ownerID, gameId: game.gameId,
            numberOfPlayers: game.p_numberOfPlayers,
            bookedPlayers: game.bookedPlayers,),),
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> showGame(context),
      child: game.p_imageURL == null ? Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            children: <Widget>[
              Icon(Icons.terrain,size: 100,color: Colors.white,),
              Text('No picture',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),)
            ],
          )) :

      cachedNetworkImage(game.p_imageURL),
    );
  }
}
