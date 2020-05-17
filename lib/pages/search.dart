import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/game.dart';
import 'package:com/models/user.dart';
import 'package:com/pages/login_page.dart';
import 'package:com/pages/player_game_page.dart';
import 'package:com/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:transparent_image/transparent_image.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResults;
  String gender = "Male";
//  UserResult searchResult;

  handleSearch(String query){
//    Future<QuerySnapshot> users = userRef
//        .where("displayName",isGreaterThanOrEqualTo:  query.toUpperCase()).
//    where("userType",isEqualTo: "Player").where("gender",isEqualTo: "Male" )
//        .getDocuments();
  if(gender == "Male") {
    Future<QuerySnapshot> games = allGamesRef
        .where("p_name", isGreaterThanOrEqualTo: query.toUpperCase(), )
        .where("p_gender",isGreaterThanOrEqualTo: gender)
        .getDocuments();
    setState(() {
      searchResults = games;
    });
  }
  if(gender == "all") {
    Future<QuerySnapshot> games = allGamesRef
        .where("p_name", isGreaterThanOrEqualTo: query.toUpperCase())
        .getDocuments();
    setState(() {
      searchResults = games;
    });
  }

//    Future<QuerySnapshot> games = allGamesRef
//        .where("p_name", isGreaterThanOrEqualTo: query.toUpperCase())
//        .where("p_gender",isEqualTo: gender)
//        .getDocuments();
//    setState(() {
//      searchResults = games;
//    });


  }

  clearSearch(){
    searchController.clear();
  }

  AppBar buildSearchField(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a Game...",
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.blueAccent,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueAccent,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults(){
    return FutureBuilder(
      future: searchResults,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc){
//          User user = User.formDocument(doc);
        Game game = Game.formDocument(doc);
          UserResult searchResult = UserResult(game);
          searchResults.add(searchResult);
        });
        return Container(
          color: Colors.blueAccent,
//          height: MediaQuery.of(context).size.height *0.7,
          child: searchResults.isEmpty ? Container() :ListView(
//              shrinkWrap: true,
            children: [
              RaisedButton(
                onPressed: () {
                  setState(() {
                    searchResults = null;
                    gender = "Female";
                  });
                },
                child: Text('Clear'),
              ),
              SingleChildScrollView(
                child: Column(
                  children: searchResults,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: Container(
    child: searchResults ==null  ? buildNoContent() :buildSearchResults(),
    ),
    );
  }
}

//searchResults == null ? buildNoContent() : buildSearchResults(),

class UserResult extends StatelessWidget {
//  final User user;
final Game game;
  UserResult(this.game);

buildGameHeader(){
  return FutureBuilder(
    future: userRef.document(game.ownerID).get(),
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
      return Container(
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
        ),
      ) ;
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[

        Card(
          margin: EdgeInsets.all(8.0),
          elevation:  5.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                buildGameHeader(),
//                Divider(),
              SizedBox(
                height: 0.5,
                child: Container(color: Colors.black,),),
                ListTile(
                  title: Text(game.p_name,style: TextStyle(
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
                      Text(Moment.now().from(game.created
                          .toDate(),),
                      ),
                    ],
                  ),
                ),
                game.p_imageURL == null ? Container() : GestureDetector(
                  onTap: (){
                    if(currentUser.userType == 'Player'){
                      Navigator.push(context, MaterialPageRoute(builder:
                          (context) =>
                          PlayerGamePage(gameId: game.gameId, ownerId: game.ownerID,gamePhotoUrl: game.p_imageURL,gameName: game.p_name
                            ,lat: game.p_lat, long: game.p_long, adress: game.p_location,bookedPlayers:game.bookedPlayers,
                          ),
                      ),
                      );
                      print('showing player post');
                    }
                  },
                  child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: game.p_imageURL,
                    fit: BoxFit.fill,
                    width: 150,
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 2.0,
          color: Colors.white54,
        ),
      ],
    );
  }
}

//GestureDetector(
//onTap: () => print('show profile'),
//child: ListTile(
//leading: CircleAvatar(
//backgroundColor: Colors.grey,
//backgroundImage: CachedNetworkImageProvider(game.p_imageURL),
//),
//title: Text(
//game.p_name,
//style:
//TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//),
//subtitle: Text(
//game.p_phoneNumber,
//style: TextStyle(color: Colors.white),
//),
//),
//),