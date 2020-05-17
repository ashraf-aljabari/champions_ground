import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com/models/user.dart';
import 'package:com/pages/login_page.dart';
import 'package:com/pages/player_home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:com/pages/home_page.dart';
import 'package:com/widgets/rounded_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Im;

//final GoogleSignIn googleSignIn = GoogleSignIn();
//final StorageReference storageRef = FirebaseStorage.instance.ref();
//final usersRef = Firestore.instance.collection('users');
//final DateTime timestamp = DateTime.now();


class CreateAccount extends StatefulWidget {


  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  //GoogleSignIn googleSignIn = GoogleSignIn();
//  final GoogleSignIn googleSignIn = GoogleSignIn();
//  final StorageReference storageReference = FirebaseStorage.instance.ref();
//  final usersRef = Firestore.instance.collection('users');
  Firestore _firestore = Firestore.instance;

  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();


   TextEditingController gender = TextEditingController();
   TextEditingController phoneNumberEdit = TextEditingController();
   TextEditingController bioEditText = TextEditingController();
   TextEditingController usernameEditText = TextEditingController();
  bool selectedGenderMale = false;
  bool selectedGenderFemale = false;
  //String gender;
  List<String> _userType = ['Owner', 'Player'];
  List<String> _gender = ['Male', 'Female'];
  String selectedGender;
  String selectedUserType;
  bool isAuth = false;
  String birthDate = 'press here to pick your age...';


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


  submit() async{
    //final GoogleSignInAccount user = googleSignIn.currentUser;
    //DocumentSnapshot doc = await userRef.document(user.id).get();

    if(phoneNumberEdit.text.trim().length ==0 && phoneNumberEdit.text.trim().length >10 && phoneNumberEdit.text.trim().length < 10){
      _key.currentState.showSnackBar(SnackBar(content: Text('phone number is wrong!'),));
      return;
    }
    if(usernameEditText.text.trim().length > 20 || usernameEditText.text.trim().length < 3){
      _key.currentState.showSnackBar(SnackBar(content: Text('username is too long or too short!'),));
      return;
    }
    if(bioEditText.text.trim().length > 100){
      _key.currentState.showSnackBar(SnackBar(content: Text('bio can\'t be more tham 100 charcters!'),));
      return;
    }
    if(gender.text.isEmpty){
      _key.currentState.showSnackBar(SnackBar(content: Text('you need to pick your gender!'),));
      return;
    }
    if(selectedUserType.isEmpty){
      _key.currentState.showSnackBar(SnackBar(content: Text('you need to pick your user type!'),));
      return;
    }
    if(birthDate == 'press here to pick your age...'){
      _key.currentState.showSnackBar(SnackBar(content: Text('you need to pick your age!'),));
      return;
    }

    try{
       await userRef.document(googleSignIn.currentUser.id).setData({
        "id": googleSignIn.currentUser.id,
        "username": usernameEditText.text.trim(),
        "photoUrl": googleSignIn.currentUser.photoUrl,
        "email": googleSignIn.currentUser.email,
        "displayName": googleSignIn.currentUser.displayName,
        "bio": bioEditText.text.trim(),
        "age": birthDate,
        "gender": selectedGender,
        "userType": selectedUserType,
        "phonenumber": phoneNumberEdit.text.trim()
      });
    }catch(err){
      print(err);
    }finally{
      usernameEditText = null;
      bioEditText = null;
      phoneNumberEdit = null;
      birthDate = 'press here to pick your age...';
      gender = null;
      //selectedUserType = null;
    }
    DocumentSnapshot doc = await userRef.document(googleSignIn.currentUser.id).get();
    currentUser = User.formDocument(doc);
    //Navigator.pop(context);
//    if(selectedUserType == 'Owner') {
//      Navigator.pushReplacement(
//          context, MaterialPageRoute(builder: (context) => LoginPage()));
//    }
//    if(selectedUserType == 'Player'){
//
//    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
    }

  @override
  void dispose(){
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _scaffoldKey,
//      appBar: header(context,
//          titleText: "set up your profile", removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      'Setup your profile info:',
                      style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Divider(color: Colors.black,thickness: 1,),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: usernameEditText,
                    //enabled: false,
                    //initialValue: '${userIfno.phoneNumber}',
                    //style: TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        FontAwesomeIcons.user,
                        color: Colors.blue,
                      ),
                      labelText: 'Username',
                      hintText: 'type your username ...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextFormField(
                    maxLines: 3,
                    maxLength: 100,
                    keyboardType: TextInputType.text,
                    controller: bioEditText,
                    //enabled: false,
                    //initialValue: '${userIfno.phoneNumber}',
                    //style: TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        FontAwesomeIcons.info,
                        color: Colors.blue,
                      ),
                      labelText: 'Bio',
                      hintText: 'tell us about yourself ...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: phoneNumberEdit,
                    //enabled: false,
                    //initialValue: '${userIfno.phoneNumber}',
                    //style: TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        FontAwesomeIcons.phone,
                        color: Colors.blue,
                      ),
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number ...',
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
                    children: <Widget>[
                      Padding(
                      padding: EdgeInsets.only(left: 20.0),
                        child: Text('Age:' ,style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                      FlatButton(
                       // color: Theme.of(context).accentColor,
                        //padding: EdgeInsets.only(left: 40.0),
                        onPressed: (){
                          DatePicker.showDatePicker(context,showTitleActions: true,
                          minTime: DateTime(1950, 1, 1),
                            maxTime: DateTime.now(),
                            onChanged: (date){
                            print('changed $date');
                            setState(() {
                             // birthDate = date;
                            });
                            },
                            onConfirm: (date){
                            print('confirmed $date');
                            setState(() {
                              //birthDate = "${date.day}/${date.month}/${date.year}";
                              DateTime yearNow = DateTime.now();
                              int age = yearNow.year - date.year;
                              birthDate = age.toString();
                              //birthDate = ('${date.year}/${date.month}/${date.day}');
                              //var date = DateTime.parse(birthDate);
//                      var formattedDate = "${date.day}-${date.month}-${date.year}";
//                      birthDate = DateTime.parse(formattedString);
                            });
                            }
                          );
                        },
                        child: Text('$birthDate', style: TextStyle(
                        fontSize: 17.0,
                        ),
                        ),
                      ),
                    ],
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
                            controller: gender,
                            enabled: false,
                            //initialValue: '${userIfno.phoneNumber}',
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                                prefixIcon: genderIcon(),
                                labelText: 'Gender',
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
                                  gender.text = selectedGender;

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
                Divider(color: Colors.black,),
                Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0,top: 16.0,bottom: 10),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                         RichText(
                          text:  TextSpan(
                            style:  TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                               TextSpan(text: 'Owner:',style: TextStyle(
                              fontWeight: FontWeight.w900,decoration: TextDecoration.underline)
                          ),
                               TextSpan(
                                  text: '  if you\'ve got a playground and want people to rent it through our app.',
                                 style: TextStyle(fontSize: 13
                                 ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RichText(
                          text:  TextSpan(
                            style:  TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: 'Player:',style: TextStyle(
                                  fontWeight: FontWeight.w900,decoration: TextDecoration.underline)
                              ),
                              TextSpan(
                                text: '  to book playground\'s with your friend\'s or alone and '
                                    'find another teammates to play your favorite sport with you!',
                                style: TextStyle(fontSize: 13
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0,bottom: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Text(
                            'User Type:',
                            style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w900) ,
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(right: 50.0)),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(canvasColor: Colors.lightBlueAccent[100]),
                          child: DropdownButton(
                            hint: Text('Select your type...'),
                            value: selectedUserType,
                            onChanged: (newValue) {
                              setState(() {
                                selectedUserType = newValue;
                              });
                            },
                            items: _userType.map((userType) {
                              return DropdownMenuItem(
                                child: Text(userType),
                                value: userType,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(color: Colors.black,),
                RoundedButton(
                    title: 'Submit',
                    color: Colors.blueAccent,
                    onPressed: () {
                      setState(() {
//                        currentUser.phoneNumber;
//                         Navigator.pop(
//                            context,
//                            MaterialPageRoute(
//                                builder: (BuildContext context) =>
//                                    MyHomePage()));
//                      data.phoneNumber = phoneNumber;
//                      Navigator.pop(context);
                      //print('$phoneNumber $username $selectedGender $selectedUserType');
                        submit();
                        //Navigator.pop(context);
                      });
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
//  void getDataBack(){
//    Data getItBack = Data(phoneNumber);
//    Navigator.pop(context,getItBack);
//  }
}
