
import 'dart:io';
import 'package:com/pages/maps.dart';
import 'package:image/image.dart' as Im;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/user.dart';
import 'package:com/pages/home_page.dart';
import 'package:com/pages/login_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_map_location_picker/generated/i18n.dart' as location_picker;
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UploadPage extends StatefulWidget {

  User currentUserId;

  UploadPage({this.currentUserId});


  @override
  _UploadPageState createState() => _UploadPageState();
}
class _UploadPageState extends State<UploadPage> {

  LocationResult _pickedLocation;

  TextEditingController locationController = TextEditingController();
  TextEditingController p_NameController = TextEditingController();
  TextEditingController p_InfoController = TextEditingController();
  TextEditingController p_PhoneNumber = TextEditingController();
  TextEditingController p_Price = TextEditingController();
  TextEditingController p_Gender = TextEditingController();
  TextEditingController p_NumberOfPlayers = TextEditingController();

  Firestore _firestore = Firestore.instance;

  String gameId = Uuid().v4();



  List<String> _gender = ['Male', 'Female'];
  String selectedGender;

  bool selectedGenderMale = false;
  bool selectedGenderFemale = false;
  bool noGenderSelected = true;
  bool isUploading = false;


  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  String p_lat;
  String p_long;
  File file;

  Icon genderIcon(){
    if(selectedGenderMale){
      return Icon(
        FontAwesomeIcons.mars,
        color: Colors.blue,
      );
    }    if(selectedGenderFemale){
      return Icon(
        FontAwesomeIcons.venus,
        color: Colors.blue,
      );
    }
     return Icon(
      FontAwesomeIcons.venusMars,
      color: Colors.blue,
    );
  }

  @override
  void dispose(){
    super.dispose();
  }

  post()async{
    setState(() {
      isUploading = true;
    });
    if(locationController.text.trim().length == 0){
      _key.currentState.showSnackBar(SnackBar(content: Text('Location can\'t be empty!'),));
      return;
    }
    if(p_NameController.text.trim().length == 0){
      _key.currentState.showSnackBar(SnackBar(content: Text('Playground name is empty!'),));
      return;
    }
    if(p_InfoController.text.trim().length == 0){
      _key.currentState.showSnackBar(SnackBar(content: Text('playground information can\'t be empty!'),));
      return;
    }
    if(p_PhoneNumber.text.trim().length ==0 && p_PhoneNumber.text.trim().length >10 && p_PhoneNumber.text.trim().length < 10){
      _key.currentState.showSnackBar(SnackBar(content: Text('playground phone number can\'t be empty or wrong!'),));
      return;
    }
    if(p_Price.text.trim().length == 0){
      _key.currentState.showSnackBar(SnackBar(content: Text('playground price can\'t be empty!'),));
      return;
    }
    if(p_NumberOfPlayers.text.trim().isEmpty){
      _key.currentState.showSnackBar(SnackBar(content: Text('playground number of players can\'t be empty!'),));
      return;
    }
    if(p_Gender.text.trim().isEmpty){
      _key.currentState.showSnackBar(SnackBar(content: Text('you need to pick players gender!'),));
    }

    DocumentReference ref;
    StorageReference ref1;


    print(widget.currentUserId.id + widget.currentUserId.fullName);
    try{
//      ref = await gameRef.document(currentUser.id).collection('userGames').add({
//        "p_name": p_NameController.text.trim(),
//        "owner": googleSignIn.currentUser.id,
//        "p_info": p_InfoController.text.trim(),
//        "p_price": p_Price.text.trim(),
//        "p_phoneNumber": p_PhoneNumber.text.trim(),
//        "p_location": locationController.text.trim(),
//        "likes": {},
//        "p_lat": p_lat,
//         "p_long": p_long,
//        "p_gender": p_Gender.text,
//        "p_numberOfPlayers": p_NumberOfPlayers.text,
//        //"gameId": ref.documentID,
//        "created": DateTime.now(),
//      });

      await gameRef.document(widget.currentUserId.id).collection('userGames').document(gameId).setData({
        "p_name": p_NameController.text.trim(),
        "owner": widget.currentUserId.id,
        "p_info": p_InfoController.text.trim(),
        "p_price": p_Price.text.trim(),
        "p_phoneNumber": p_PhoneNumber.text.trim(),
        "p_location": locationController.text.trim(),
        "likes": {},
        "p_lat": p_lat,
        "p_long": p_long,
        "p_gender": p_Gender.text,
        "p_numberOfPlayers": p_NumberOfPlayers.text,
        "gameId": gameId,
        "created": DateTime.now(),
        "bookedPlayers": 0,
      });
      await allGamesRef.document(gameId).setData({
        "p_name": p_NameController.text.trim(),
        "owner": widget.currentUserId.id,
        "p_info": p_InfoController.text.trim(),
        "p_price": p_Price.text.trim(),
        "p_phoneNumber": p_PhoneNumber.text.trim(),
        "p_location": locationController.text.trim(),
        "likes": {},
        "p_lat": p_lat,
        "p_long": p_long,
        "p_gender": p_Gender.text,
        "p_numberOfPlayers": p_NumberOfPlayers.text,
        "gameId": gameId,
        "created": DateTime.now(),
        "bookedPlayers": 0,
      });

//      _firestore.collection('gamesID').document(ref.documentID).setData({
//        "playersBooked": {},
//        "maxNumberOfPlayers": p_NumberOfPlayers.text,
//      });

      if(file != null) {
        _key.currentState.removeCurrentSnackBar();
        _key.currentState.showSnackBar(
            SnackBar(content: Text('Uploading Image, Please wait...'),));
        await compressImage();
        String url = await uploadImageAndGetUrl(file);
        await gameRef.document(widget.currentUserId.id).collection('userGames').document(gameId).updateData({
          "imageURL": url
        });
        await allGamesRef.document(gameId).updateData({
          "imageURL": url
        });
//        await ref.updateData({
//
//        });
      }
      _key.currentState.removeCurrentSnackBar();
      _key.currentState.showSnackBar(SnackBar(content: Text('playground created successfuly!',textAlign: TextAlign.center,),));

      Future.delayed(Duration(seconds: 1),(){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
      });
    }catch(err){
      print(err.toString());
      _key.currentState.showSnackBar(SnackBar(content: Text('$err',textAlign: TextAlign.center,),));
      setState(() {
        isUploading = false;
      });

    }finally{
      file = null;
      p_long = null;
      p_lat = null;
      p_PhoneNumber = null;
      p_Price = null;
      p_InfoController = null;
      p_NameController = null;
      locationController = null;
      selectedGender = null;
      p_Gender = null;
      p_NumberOfPlayers = null;
      gameId = Uuid().v4();
      isUploading = false;
    }

  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$gameId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImageAndGetUrl(File file)async{
//    FirebaseStorage storage = FirebaseStorage.instance;
//    StorageUploadTask task = storage.ref().child(filename).putFile(
//      file,StorageMetadata(contentType: 'image/png'));
//    final String downloadURL = await (await task.onComplete).ref.getDownloadURL();
    StorageUploadTask uploadTask = storageRef.child('game_$gameId.jpg').putFile(file);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadURL = await storageSnap.ref.getDownloadURL();

    return downloadURL;

  }


  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality}'
        ' ${placemark.locality}, ${placemark.subAdministrativeArea}, '
        '${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress = "${placemark.subLocality}, ${placemark.locality}, ${placemark.country}";
    print(formattedAddress);
    locationController.text = formattedAddress;
    p_lat = position.latitude.toString();
    p_long = position.longitude.toString();

  }

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"), onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  locationMaps()async{
//    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
//      builder: (context) =>
//    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Add playground"),
      ),
      body: ListView(
        children: <Widget>[
          file == null ? Padding(
          padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                child: Icon(FontAwesomeIcons.image,size: 150,),
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Colors.blue,
                  ),
                ),
              ),
              //            decoration: BoxDecoration(
//              borderRadius: BorderRadius.circular(25.0),
//              border: Border.all(
//                color: Colors.blue,
//              ),
//            ),
              Positioned(
                //top: 4.0,
                right: 4.0,
                bottom: 4.0,
                child: IconButton(icon: Icon(FontAwesomeIcons.plusCircle),color: Colors.black,
                    onPressed: (){
                      selectImage(context);
                    }),
              )
            ],
          ),
        ],
      ),
    ) :
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      child: Image.file(file,fit: BoxFit.cover,),
                      width: 250,
                      height: 250,
                    ),
                    Positioned(
                      top: 4.0,
                      right: 4.0,
                      child: IconButton(icon: Icon(Icons.close),color: Colors.white,
                          onPressed: (){
                            setState(() {
                              file = null;
                            });
                          }),
                    )
                  ],
                ),
              ],
            ),
          ),

          Text('Tip: it is optinal to post your playground pricture',
            textAlign: TextAlign.center,style:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
          Divider(color: Colors.black,thickness: 1,),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: p_NameController,
              //enabled: false,
              //initialValue: '${userIfno.phoneNumber}',
              //style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  FontAwesomeIcons.book,
                  color: Colors.blue,
                ),
                labelText: 'playground name',
                hintText: 'type playground name ...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
//           Container(
//             margin: EdgeInsets.all(8.0),
//            padding: EdgeInsets.all(8.0),
//            decoration: BoxDecoration(
//              borderRadius: BorderRadius.circular(25.0),
//              border: Border.all(
//                color: Colors.blue,
//              ),
//            ),
//            child: TextField(
//              controller: p_NameController,
//              decoration: InputDecoration(
//                hintText: 'playground name ...',
//                border: InputBorder.none,
//              ),
//            ),
//          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextFormField(
              maxLength: 300,
              maxLines: 3,
              keyboardType: TextInputType.text,
              controller: p_InfoController,
              //enabled: false,
              //initialValue: '${userIfno.phoneNumber}',
              //style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  FontAwesomeIcons.info,
                  color: Colors.blue,
                ),
                hintText: 'Tell us about your playground ...',
                labelText: 'Playground info',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              controller: p_PhoneNumber,
              //enabled: false,
              //initialValue: '${userIfno.phoneNumber}',
              //style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  FontAwesomeIcons.phone,
                  color: Colors.blue,
                ),
                labelText: 'Phone Number',
                hintText: 'Playground phone number ...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: p_Price,
              //enabled: false,
              //initialValue: '${userIfno.phoneNumber}',
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  FontAwesomeIcons.dollarSign,
                  color: Colors.blue,
                ),
                labelText: 'Price',
                hintText: 'Seassion price per hour ...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: p_NumberOfPlayers,
              //enabled: false,
              //initialValue: '${userIfno.phoneNumber}',
              //style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  FontAwesomeIcons.users,
                  color: Colors.blue,
                ),
                labelText: 'number of players',
                hintText: 'number of players allwoed ...',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      //keyboardType: TextInputType.number,
                      controller: p_Gender,
                      enabled: false,
                      //initialValue: '${userIfno.phoneNumber}',
                      //style: TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixIcon: genderIcon(),
                        labelText: 'Gender',
                        hintText: 'Seassion price per hour ...',
                        border: InputBorder.none
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 55.0,
                    width: 1.0,
                    child: Container(
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0,right: 5.0,top: 5.0),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(canvasColor: Colors.lightBlueAccent[100]),
                      child: DropdownButton(
                        hint: Text('Select your gender...'),
                        value: selectedGender,
                        onChanged: (newValue) {
                          setState(() {
                            selectedGender = newValue;

                            if(newValue == "Male"){
                              selectedGenderMale = true;
                            }else {
                              selectedGenderMale = false;
                            }
                              if(newValue == "Female"){
                              selectedGenderFemale = true;
                            }else{
                                selectedGenderFemale = false;
                            }
                            p_Gender.text = selectedGender;

                          });
                        },
                        items: _gender.map((gender) {
                          return DropdownMenuItem(
                            child: Text(gender),
                            value: gender,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Playground location ...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
//            width: 200.0,
//            height: 100.0,
                alignment: Alignment.center,
                child: RaisedButton.icon(
                  label: Text(
                    " Pick Location",
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  color: Colors.blue,
                  onPressed: ()async{
//                    LocationResult results = await Navigator.push(context, MaterialPageRoute(builder: (context)=>MapSamplePage()));
                    //locationMaps();
                    LocationResult result = await showLocationPicker(
                      context,
                      "AIzaSyAcLLyO1mEseiDhj7L1Yw2WRuBMRhKxQJo",
                      initialCenter: LatLng(31.1975844, 29.9598339),
                      automaticallyAnimateToCurrentLocation: true,
                      mapStylePath: 'assets/mapStyle.json',
                      myLocationButtonEnabled: true,
                      layersButtonEnabled: true,
                      resultCardAlignment: Alignment.bottomCenter,
                    );
                    print(result.latLng.longitude);
                    print(result.latLng.latitude);

                    setState(() {
                      locationController.text = result.address.toString();
                      p_long = result.latLng.longitude.toString();
                      p_lat = result.latLng.latitude.toString();
                    });

                  },
                  icon: Icon(
                    FontAwesomeIcons.mapMarkedAlt,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
//            width: 200.0,
//            height: 100.0,
                alignment: Alignment.center,
                child: RaisedButton.icon(
                  label: Text(
                    "Use Current Location",
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  color: Colors.blue,
                  onPressed: getUserLocation,
                  icon: Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
//            width: 200.0,
//            height: 100.0,
                alignment: Alignment.center,
                child: RaisedButton.icon(
                  label: Text(
                    "Create Playground",
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  color: Colors.blue,
                  onPressed: isUploading ? null :() => post(),
                  icon: Icon(
                    Icons.send,
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
}
