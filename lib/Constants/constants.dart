// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:twitter_clone/Database/auth_method.dart';
import 'package:twitter_clone/Screen/Chats/chat_page.dart';

import 'package:twitter_clone/Screen/Home/home.dart';
import 'package:twitter_clone/Screen/Live/feed.dart';

import 'package:twitter_clone/Screen/Profile/userProfile.dart';
import 'package:twitter_clone/Screen/Search/search.dart';
import 'package:twitter_clone/main.dart';


const ONESIGNAL_APP_ID = '';
var firestore = FirebaseFirestore.instance;
const appId = '';
const tempId =
    "";
const baseUrl = '';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

var userId = FirebaseAuth.instance.currentUser!.uid;
var auth = FirebaseAuth.instance;
var authClass = AuthMethod();
List pages = [
  const HomeScreen(),
  SearchScreen(),
  const LiveFeed(),
  UserProfilePage(),
  const ChatPage(),
];
void toastMessage(String? message) {
  Fluttertoast.showToast(
      msg: message.toString(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);
}

final storageRef = FirebaseStorage.instance.ref();
Future<http.Response> sendNotification(
    List<String> tokenIdList, String contents, String heading) async {
  return await post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      "app_id":
          ONESIGNAL_APP_ID, //kAppId is the App Id that one get from the OneSignal When the application is registered.

      "include_player_ids":
          tokenIdList, //tokenIdList Is the List of All the Token Id to to Whom notification must be sent.

      // android_accent_color reprsent the color of the heading text in the notifiction
      "android_accent_color": "FF9976D2",

      "small_icon": "ic_stat_onesignal_default",

      "large_icon": "",

      "headings": {"en": heading},

      "contents": {"en": contents},
    }),
  );
}


// Two Image Setting


// StaggeredGridTile
//                                                               .count(
//                                                                   crossAxisCellCount:
//                                                                       2,
//                                                                   mainAxisCellCount:
//                                                                       4,
//                                                                   child: Image
//                                                                       .network(
//                                                                     "https://static01.nyt.com/images/2011/01/14/arts/14MOVING-span/MOVING-jumbo.jpg",
//                                                                     fit: BoxFit
//                                                                         .cover,
//                                                                   )),
//                                                           StaggeredGridTile
//                                                               .count(
//                                                                   crossAxisCellCount:
//                                                                       2,
//                                                                   mainAxisCellCount:
//                                                                       4,
//                                                                   child: Image
//                                                                       .network(
//                                                                     "https://static01.nyt.com/images/2011/01/14/arts/14MOVING-span/MOVING-jumbo.jpg",
//                                                                     fit: BoxFit
//                                                                         .cover,
//                                                                   )),


/// Four Image Setting


  //  StaggeredGridTile
  //                                                             .count(
  //                                                                 crossAxisCellCount:
  //                                                                     2,
  //                                                                 mainAxisCellCount:
  //                                                                     2,
  //                                                                 child: Image
  //                                                                     .network(
  //                                                                   "https://static01.nyt.com/images/2011/01/14/arts/14MOVING-span/MOVING-jumbo.jpg",
  //                                                                   fit: BoxFit
  //                                                                       .cover,
  //                                                                 )),
  //                                                         StaggeredGridTile
  //                                                             .count(
  //                                                                 crossAxisCellCount:
  //                                                                     2,
  //                                                                 mainAxisCellCount:
  //                                                                     2,
  //                                                                 child: Image
  //                                                                     .network(
  //                                                                   "https://static01.nyt.com/images/2011/01/14/arts/14MOVING-span/MOVING-jumbo.jpg",
  //                                                                   fit: BoxFit
  //                                                                       .cover,
  //                                                                 )),
  //                                                         StaggeredGridTile
  //                                                             .count(
  //                                                                 crossAxisCellCount:
  //                                                                     1,
  //                                                                 mainAxisCellCount:
  //                                                                     2,
  //                                                                 child: Image
  //                                                                     .network(
  //                                                                   "https://static01.nyt.com/images/2011/01/14/arts/14MOVING-span/MOVING-jumbo.jpg",
  //                                                                   fit: BoxFit
  //                                                                       .cover,
  //                                                                 )),
  //                                                         StaggeredGridTile
  //                                                             .count(
  //                                                                 crossAxisCellCount:
  //                                                                     3,
  //                                                                 mainAxisCellCount:
  //                                                                     2,
  //                                                                 child: Image
  //                                                                     .network(
  //                                                                   "https://static01.nyt.com/images/2011/01/14/arts/14MOVING-span/MOVING-jumbo.jpg",
  //                                                                   fit: BoxFit
  //                                                                       .cover,
  //                                                                 )),
