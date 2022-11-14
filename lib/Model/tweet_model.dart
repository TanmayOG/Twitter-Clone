import 'package:flutter/widgets.dart';

class TweetModel with ChangeNotifier {
  String? uid;
  String? tweets;
  String? image;
  var timestamp;
  var likes;
  var retweets;
  var creator;
  var username;
  var email;

  TweetModel(
      {this.uid,
      this.tweets,
      this.image,
      this.timestamp,
      this.likes,
      this.retweets,
      this.creator,
      this.email,
      this.username});
}
