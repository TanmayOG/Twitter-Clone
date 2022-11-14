import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../Constants/constants.dart';

class UserProvider with ChangeNotifier {
  // getter and setter
  String? username;
  String? email;
  String? bio;
  String? profilePhotoUrl;
  var date = null;
  var tokenId;
  var follower;
  var cover;
  var following;

  UserProvider() {
    getUserData();
    print('UserProvider');
  }

  getUserData() async {
    var userVideo = await firestore
        .collection('users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (userVideo.docs.isNotEmpty) {
      username = (userVideo.docs[0].data() as dynamic)['username'] as String;

      email = (userVideo.docs[0].data() as dynamic)['email'] as String;
      profilePhotoUrl =
          (userVideo.docs[0].data() as dynamic)['image'] as String;
      follower = (userVideo.docs[0].data() as dynamic)['follower'] as int;
      following = (userVideo.docs[0].data() as dynamic)['following'] as int;
      date = (userVideo.docs[0].data() as dynamic)['date'];
      bio = (userVideo.docs[0].data() as dynamic)['bio'] as String;

      tokenId = (userVideo.docs[0].data() as dynamic)['tokenId'] as String;
      cover = (userVideo.docs[0].data() as dynamic)['cover'] as String;
      // notifyListeners();
    } else {
      username = '';
      email = '';
      profilePhotoUrl = '';

      tokenId = '';

      follower = 0;
      following = 0;
    }

    notifyListeners();
  }
}
