import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/main.dart';
import 'package:com/models/game.dart';
import 'package:com/pages/login_page.dart';
import 'package:com/pages/maps.dart';
import 'package:com/widgets/progress.dart';
import 'package:flutter/material.dart';


class PlayerHomePage extends StatefulWidget {
  @override
  _PlayerHomePageState createState() => _PlayerHomePageState();
}




class _PlayerHomePageState extends State<PlayerHomePage> {

//  List<Story> _stories;
List<Game> games;

@override
void initState() {
  super.initState();
  getGames();
}
getGames()async{
  QuerySnapshot snapshot = await allGamesRef
      .orderBy('created',descending: true).getDocuments();
  if(snapshot.documents.isNotEmpty){
    List<Game> games = snapshot.documents.map((doc)=> Game.formDocument(doc)).toList();
    print(snapshot);
    setState(() {
      this.games = games;
    });
  }

}

  buildGamesTimeline(){
  if(games == null){
    return circularProgress();
  }else if(games.isEmpty){
    return;
  }else{
    return ListView(children: games,);
  }
  }
  List<Story> _stories = <Story>[
  Story(
  name: 'Community',
  storyUrl: 'https://wallpaperaccess.com/full/1079198.jpg',
  email: 'waleedarshad@gmail.com'),
  Story(
  name: 'Google',
  storyUrl:
  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdx5NkTqe7sjEU1vNXBl-X_v8t5cBM21L-vOs_z6qwVu5JLHjKhw&s',
  email: 'flutter.khi@gmail.com',
  ),
  Story(
  name: 'Dart',
  storyUrl:
  'https://images.unsplash.com/photo-1535370976884-f4376736ab06?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
  email: 'flutterkarachi@gmail.com',
  ),
  Story(
  name: 'Dart',
  storyUrl: 'https://wallpaperplay.com/walls/full/7/c/f/34782.jpg',
  email: 'helloworld@gmail.com',
  ),
  Story(
  name: 'Dart',
  storyUrl:
  'https://pbs.twimg.com/profile_images/779305023507271681/GJJhYpD2_400x400.jpg',
  email: 'google@google.com',
  ),
  Story(
  name: 'Dart',
  storyUrl:
  'https://d33wubrfki0l68.cloudfront.net/495c5afa46922a41983f6442f54491c862bdb275/67c35/static/images/wallpapers/playground-07.png',
  email: 'gmail@google.com',
  ),
  ];

  SizedBox _buildStoryListView() {
    return SizedBox(
      height: 150.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stories.length,
        itemExtent: 100.0,
        itemBuilder: (context, index) {
          var item = _stories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    item.storyUrl,
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black26,
                    BlendMode.darken,
                  ),
                ),
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: CircleAvatar(

                        backgroundImage: NetworkImage(
                          'https://iisy.fi/wp-content/uploads/2018/08/user-profile-male-logo.jpg',
                        ),
                        radius: 14.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item.name,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),),
      body: RefreshIndicator(
        onRefresh: () => getGames(),
        child: buildGamesTimeline(),
      ),
    );
  }
}

//Scaffold(
//appBar: AppBar(title: Text('Home Page'),),
//body: Column(
//children: <Widget>[
//Padding(
//padding: const EdgeInsets.all(4.0),
//child: TextFormField(
//decoration: InputDecoration(
//border: OutlineInputBorder(),
//hintText: 'Enter text to search',
//labelText: 'Search',
//prefixIcon: Icon(Icons.search)),
//),
//),
//Expanded(
//child: ListView(
//children: <Widget>[
//_buildStoryListView(),
//RaisedButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>MapSamplePage())),
//child: Text('Maps'),),
////                _buildCardListView(),
////                _buildRequestListView(),
//],
//),
//),
//],
//)
//);

class Story {
  final String name;
  final String email;
  final String storyUrl;

  Story({this.name, this.storyUrl, this.email});
}