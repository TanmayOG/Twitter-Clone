import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

import 'package:twitter_clone/Widgets/font.dart';
import 'package:twitter_clone/Widgets/full_image.dart';
import 'package:twitter_clone/Widgets/imageswipe.dart';

import '../Constants/constants.dart';

commentSheet(BuildContext context, postid, tokenId) async {
  TextEditingController _controller = TextEditingController();
  return showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      barrierColor: Colors.grey.withOpacity(0.1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                Divider(
                  thickness: 4,
                  indent: 150,
                  endIndent: 150,
                  color: Colors.white,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Comment', style: usernamePF),
                ),
                Expanded(
                  child: ListTile(
                    title: TextFormField(
                      // focusNode: _focusNode,
                      controller: _controller,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            authClass.postComment(
                                _controller.text, postid, tokenId);

                            _controller.clear();
                          },
                        ),
                        hintText: 'Add a comment',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: FutureBuilder(
                      future: authClass.showComment(postid),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CupertinoActivityIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text("Something went wrong"));
                        } else if (snapshot.data.length == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Center(
                                  child: Text(
                                    'No comments yet',
                                    style: usernamePF,
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    'Be the first to comment',
                                    style: captionF,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          var data = snapshot.data;

                          return ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              // reverse: true,
                              itemCount: data.length,
                              itemBuilder: (context, index) => ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.black,
                                      backgroundImage: NetworkImage(
                                          data[index]['userImage'] as String),
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          data[index]['username'] as String,
                                          style: usernameF,
                                        ),
                                        Text(data[index]['comment'] as String,
                                            style: captionF)
                                      ],
                                    ),
                                    subtitle: Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                          timeago.format(data[index]
                                                  ['timestamp']
                                              .toDate()),
                                          style: timeF),
                                    ),
                                  ));
                        }
                      }),
                ),
              ],
            );
          },
        );
      });
}

retweetSheet(context, id, name, tokenId) {
  showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.2),
      barrierColor: Colors.grey.withOpacity(0.1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Divider(
                color: Colors.white,
                thickness: 4,
                endIndent: 160,
                indent: 160,
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: GestureDetector(
                  onTap: () {
                    authClass.retweetFuction(id, name, tokenId, "");
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Retweet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: GestureDetector(
                  onTap: () {
                    quoteRetweetSheet(context, id, name, tokenId);
                  },
                  child: const Text(
                    'Retweet with quote',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

quoteRetweetSheet(context, id, name, tokenId) {
  var tweets;
  return showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      barrierColor: Colors.grey.withOpacity(0.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    color: Colors.white,
                    thickness: 4,
                    endIndent: 160,
                    indent: 160,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          tweets = value;
                        });
                      },
                      maxLines: 20,
                      decoration: const InputDecoration(
                        hintText: 'What\'s happening?',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          authClass.retweetFuction(id, name, tokenId, tweets);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Retweet",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      });
}

showDetail(
  BuildContext context,
  final id,
  final name,
  final image,
  final tweet,
  final tokenId,
  final tweetImage,
  final likes,
  final date,
  final postid,
  final retweetCount,
  // final retweet,
) async {
  // bool isReadmore = false;
  return showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      barrierColor: Colors.grey.withOpacity(0.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        var isReadmore = false;
        return StatefulBuilder(
          builder: ((context, setState) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Divider(
                      thickness: 4,
                      indent: 150,
                      endIndent: 150,
                      color: Colors.white,
                    ),
                    tweetImage.isEmpty
                        ? Container()
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                            id: tweetImage,
                                          )));
                            },
                            child: ImageSwipe(
                              imageList: tweetImage,
                              height: MediaQuery.of(context).size.height * 0.5,
                            )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(name),
                      ),
                      title: Text(
                        image.toString().toTitleCase(),
                      ),
                    ),
                    ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: buildText(tweet, isReadmore),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isReadmore = !isReadmore;
                                    });
                                  },
                                  child: tweet.length > 100
                                      ? Text(
                                          (isReadmore
                                              ? 'Show less'
                                              : 'Show more'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.bold,
                                          ))
                                      : Container()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.grey[800],
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .where('postid', isEqualTo: postid)
                            .snapshots(includeMetadataChanges: true),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Something went wrong");
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("Loading");
                          }
                          log('Lenght ::${snapshot.data!.docs.length.toString()}');
                          log(postid);
                          var tweetdata = snapshot.data!.docs;

                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: tweetdata.length,
                              itemBuilder: (context, index) {
                                var isLike =
                                    tweetdata[index]['likes'].contains(id);
                                return Row(children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04,
                                  ),
                                  Text(
                                    tweetdata[index]['retweetCount']
                                        .length
                                        .toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  const Text(
                                    "  Retweets",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontSize: 14),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04,
                                  ),
                                  Text(
                                    tweetdata[index]['likes'].length.toString(),
                                  ),
                                  const Text(
                                    "  Likes",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontSize: 14),
                                  ),
                                ]);
                              });
                        }),
                    Divider(
                      thickness: 1,
                      color: Colors.grey[800],
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .where("postid", isEqualTo: postid)
                            .snapshots(includeMetadataChanges: true),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Something went wrong");
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // CupertinoActivityIndicator();
                            return const CupertinoActivityIndicator();
                          }
                          QuerySnapshot tweetdata =
                              snapshot.data as QuerySnapshot;

                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: tweetdata.docs.length,
                              itemBuilder: (context, i) {
                                var isRetweeted =
                                    tweetdata.docs[i]['retweetCount'].contains(
                                        FirebaseAuth.instance.currentUser!.uid);

                                var isLike = tweetdata.docs[i]['likes']
                                    .contains(
                                        FirebaseAuth.instance.currentUser!.uid);
                                log(tweetdata.docs.length.toString());
                                return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.insert_comment_outlined,
                                            color: Colors.grey,
                                            size: 18),
                                        onPressed: () {
                                          commentSheet(
                                              context,
                                              tweetdata.docs[i].id,
                                              tweetdata.docs[i]['tokenId']);
                                          // _focusNode.requestFocus();
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          EvaIcons.flip,
                                          size: 18,
                                          color: isRetweeted
                                              ? const Color.fromARGB(
                                                  255, 29, 212, 38)
                                              : Colors.grey[700],
                                        ),
                                        onPressed: () {
                                          // print(checker.checker);
                                          if (isRetweeted) {
                                            authClass.retweetFuction(
                                                tweetdata.docs[i].id,
                                                tweetdata.docs[i]['username'],
                                                tweetdata.docs[i]['tokenId'],
                                                "");
                                          } else {
                                            retweetSheet(
                                              context,
                                              tweetdata.docs[i].id,
                                              tweetdata.docs[i]['username'],
                                              tweetdata.docs[i]['tokenId'],
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: isLike
                                            ? const Icon(
                                                CupertinoIcons.suit_heart_fill,
                                                size: 18,
                                                color: Colors.red,
                                              )
                                            : Icon(
                                                CupertinoIcons.suit_heart,
                                                size: 18,
                                                color: Colors.grey[500],
                                              ),
                                        onPressed: () {
                                          authClass.addLikes(
                                              id,
                                              tweetdata.docs[i].id,
                                              tweetdata.docs[i]['tokenId']);
                                        },
                                      ),
                                      id == userId
                                          ? IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.grey),
                                              onPressed: () {
                                                authClass.deletePost(
                                                    tweetdata.docs[0].id);
                                                Navigator.pop(context);
                                                // _focusNode.requestFocus();
                                              },
                                            )
                                          : Container(),
                                    ]);
                              });
                        }),
                    Divider(
                      thickness: 1,
                      color: Colors.grey[800],
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      });
}

buildText(String text, isReadmore) {
  // if read more is false then show only 3 lines from text
  // else show full text
  final lines = isReadmore ? null : 3;
  return Text(
    text, style: tweetF,
    // style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w600),
    maxLines: text.length > 5 ? lines : null,
    // overflow properties is used to show 3 dot in text widget
    // so that user can understand there are few more line to read.
    overflow: isReadmore ? TextOverflow.visible : TextOverflow.ellipsis,
  );
}
