
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String photoUrl;
  final String phoneNumber;
  final String bio;
  final String gender;
  final String userType;
  final String birthdate;
  User({
    this.id,
    this.fullName,
    this.username,
    this.email,
    this.photoUrl,
    this.phoneNumber,
    this.bio,
    this.gender,
    this.userType,
    this.birthdate
  });

  factory User.formDocument(DocumentSnapshot doc){
    return User(
      id: doc['id'],
      fullName: doc['displayName'],
      photoUrl: doc['photoUrl'],
      email: doc['email'],
      bio: doc['bio'],
      birthdate: doc['age'],
      gender: doc['gender'],
      userType: doc['userType'],
      phoneNumber: doc['phonenumber'],
      username: doc['username'],
    );
  }
}

//"id": user.id,
//"username": username,
//"photoUrl": user.photoUrl,
//"email": user.email,
//"displayName": user.displayName,
//"bio": bio,
//"age": birthDate,
//"gender": selectedGender,
//"userType": selectedUserType,