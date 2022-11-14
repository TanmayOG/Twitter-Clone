// ignore_for_file: prefer_const_constructors

// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twitter_clone/Screen/Post/add_twit.dart';
import 'package:twitter_clone/Screen/Profile/otherProfile.dart';
import 'package:twitter_clone/Widgets/cacheImage.dart';
import 'package:twitter_clone/Widgets/font.dart';
import 'package:twitter_clone/Widgets/imageswipe.dart';
import 'package:twitter_clone/Widgets/sheetHelper.dart';
import 'package:twitter_clone/Widgets/home_helper.dart';
import '../../Constants/constants.dart';
import '../../Widgets/full_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  with WidgetsBindingObserver{
  bool isReadmore = false;

    AppLifecycleState? state;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print("Hello State   $state");

  }
  @override
  void dispose() {

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  void didChangeAppLifeCycleState(AppLifecycleState appLifecycleState) {
    state = appLifecycleState;
    print("Hello State$appLifecycleState");
    print(":::::::");
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTwitt(),
                ),
              );
            },
            child: Icon(Iconsax.edit, color: Colors.white)),

        // drawer: drawer(),
        appBar: appBar(context),
        drawer: drawer(),
        // bottomSheet: ,
        body: LiquidPullToRefresh(
          color: Colors.blue,
          showChildOpacityTransition: false,
          animSpeedFactor: 3,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2)).then((value) {
              setState(() {});
            });
          },
          springAnimationDurationInMilliseconds: 700,
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(includeMetadataChanges: true),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Something went wrong"),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // place loading widget at center of screen

                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: Center(child: const CupertinoActivityIndicator()),
                    );
                  }

                  return ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var tweetdata = snapshot.data!.docs as dynamic;
                      String tweets = tweetdata[index]['tweets'];
                      var isLike = tweetdata[index]['likes']
                          .contains(FirebaseAuth.instance.currentUser!.uid);
                      var isRetweeted = tweetdata[index]['retweetCount']
                              .contains(
                                  FirebaseAuth.instance.currentUser!.uid) ??
                          false;
                      List imageList = tweetdata[index]['image'];
                      log('${imageList.length}');
                      return Container(
                        color: Colors.black,
                        // margin: EdgeInsets.only(top: 1.5),
                        child: Column(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                  title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfilePage(
                                                        id: tweetdata[index]
                                                            ['creator'],
                                                        token: tweetdata[index]
                                                            ['tokenId'],
                                                      ),
                                                    ),
                                                  ).then((value) {
                                                    debugPrint(tweetdata[index]
                                                        ['creator']);
                                                  });
                                                },
                                                child: Text(
                                                    tweetdata[index]['username']
                                                        .toString()
                                                        .toTitleCase(),
                                                    style: usernameF),
                                              ),
                                            ),
                                            Text(
                                              timeago.format(tweetdata[index]
                                                      ['timestamp']
                                                  .toDate()),
                                              style: timeF,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDetail(
                                              context,
                                              tweetdata[index]['creator'],
                                              tweetdata[index]['userImage'],
                                              tweetdata[index]['username'],
                                              tweets,
                                              tweetdata[index]['tokenId'],
                                              imageList,
                                              tweetdata[index]['likes']
                                                  .length
                                                  .toString(),
                                              tweetdata[index]['timestamp'],
                                              tweetdata[index].id,
                                              tweetdata[index]['retweetCount']
                                                  .length
                                                  .toString(),
                                            );
                                          },
                                          child: HashtagText(text: tweets),
                                        ),
                                        imageList.length == 0
                                            ? Container()
                                            : imageList.length == 2
                                                ? SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          showDetail(
                                                            context,
                                                            tweetdata[index]
                                                                ['creator'],
                                                            tweetdata[index]
                                                                ['userImage'],
                                                            tweetdata[index]
                                                                ['username'],
                                                            tweets,
                                                            tweetdata[index]
                                                                ['tokenId'],
                                                            tweetdata[index]
                                                                ['image'],
                                                            tweetdata[index]
                                                                    ['likes']
                                                                .length
                                                                .toString(),
                                                            tweetdata[index]
                                                                ['timestamp'],
                                                            tweetdata[index].id,
                                                            tweetdata[index][
                                                                    'retweetCount']
                                                                .length
                                                                .toString(),
                                                          );
                                                        },
                                                        child:
                                                            StaggeredGrid.count(
                                                          crossAxisCount: 4,
                                                          mainAxisSpacing: 4,
                                                          crossAxisSpacing: 4,
                                                          children: [
                                                            StaggeredGridTile
                                                                .count(
                                                                    crossAxisCellCount:
                                                                        2,
                                                                    mainAxisCellCount:
                                                                        4,
                                                                    child:
                                                                        CacheImage(
                                                                      imageUrl:
                                                                          imageList[
                                                                              0],
                                                                    )),
                                                            StaggeredGridTile
                                                                .count(
                                                                    crossAxisCellCount:
                                                                        2,
                                                                    mainAxisCellCount:
                                                                        4,
                                                                    child:
                                                                        CacheImage(
                                                                      imageUrl:
                                                                          imageList[
                                                                              1],
                                                                    )),
                                                          ],
                                                        ),
                                                      ),
                                                    ))
                                                : imageList.length == 4
                                                    ? SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              showDetail(
                                                                context,
                                                                tweetdata[index]
                                                                    ['creator'],
                                                                tweetdata[index]
                                                                    [
                                                                    'userImage'],
                                                                tweetdata[index]
                                                                    [
                                                                    'username'],
                                                                tweets,
                                                                tweetdata[index]
                                                                    ['tokenId'],
                                                                tweetdata[index]
                                                                    ['image'],
                                                                tweetdata[index]
                                                                        [
                                                                        'likes']
                                                                    .length
                                                                    .toString(),
                                                                tweetdata[index]
                                                                    [
                                                                    'timestamp'],
                                                                tweetdata[index]
                                                                    .id,
                                                                tweetdata[index]
                                                                        [
                                                                        'retweetCount']
                                                                    .length
                                                                    .toString(),
                                                              );
                                                            },
                                                            child: StaggeredGrid
                                                                .count(
                                                              crossAxisCount: 4,
                                                              mainAxisSpacing:
                                                                  4,
                                                              crossAxisSpacing:
                                                                  4,
                                                              children: [
                                                                StaggeredGridTile
                                                                    .count(
                                                                        crossAxisCellCount:
                                                                            2,
                                                                        mainAxisCellCount:
                                                                            2,
                                                                        child:
                                                                            CacheImage(
                                                                          imageUrl:
                                                                              imageList[0],
                                                                        )),
                                                                StaggeredGridTile
                                                                    .count(
                                                                        crossAxisCellCount:
                                                                            2,
                                                                        mainAxisCellCount:
                                                                            2,
                                                                        child:
                                                                            CacheImage(
                                                                          imageUrl:
                                                                              imageList[1],
                                                                        )),
                                                                StaggeredGridTile
                                                                    .count(
                                                                        crossAxisCellCount:
                                                                            1,
                                                                        mainAxisCellCount:
                                                                            2,
                                                                        child:
                                                                            CacheImage(
                                                                          imageUrl:
                                                                              imageList[2],
                                                                        )),
                                                                StaggeredGridTile
                                                                    .count(
                                                                        crossAxisCellCount:
                                                                            3,
                                                                        mainAxisCellCount:
                                                                            2,
                                                                        child:
                                                                            CacheImage(
                                                                          imageUrl:
                                                                              imageList[3],
                                                                        )),
                                                              ],
                                                            ),
                                                          ),
                                                        ))
                                                    : GestureDetector(
                                                        onTap: () {
                                                          showDetail(
                                                            context,
                                                            tweetdata[index]
                                                                ['creator'],
                                                            tweetdata[index]
                                                                ['userImage'],
                                                            tweetdata[index]
                                                                ['username'],
                                                            tweets,
                                                            tweetdata[index]
                                                                ['tokenId'],
                                                            tweetdata[index]
                                                                ['image'],
                                                            tweetdata[index]
                                                                    ['likes']
                                                                .length
                                                                .toString(),
                                                            tweetdata[index]
                                                                ['timestamp'],
                                                            tweetdata[index].id,
                                                            tweetdata[index][
                                                                    'retweetCount']
                                                                .length
                                                                .toString(),
                                                          );
                                                        },
                                                        onLongPress: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (_) {
                                                            return DetailScreen(
                                                              id: tweetdata[
                                                                      index]
                                                                  ['image'],
                                                            );
                                                          }));
                                                        },
                                                        child: SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.3,
                                                            child: ImageSwipe(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.3,
                                                              imageList:
                                                                  imageList,
                                                            )),
                                                      ),
                                      ]),
                                  // subtitle:
                                  leading: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfilePage(
                                            id: tweetdata[index]['creator'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundImage: NetworkImage(
                                          tweetdata[index]['userImage']
                                              as String),
                                    ),
                                  )),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.15),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: isLike
                                      ? const Icon(
                                          CupertinoIcons.heart_fill,
                                          size: 18,
                                          color: Colors.red,
                                        )
                                      : Icon(CupertinoIcons.heart,
                                          size: 16, color: Colors.grey),
                                  onPressed: () {
                                    authClass.addLikes(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      tweetdata[index].id,
                                      tweetdata[index]['tokenId'],
                                    );
                                  },
                                ),
                                Text(
                                    tweetdata[index]['likes'].length.toString(),
                                    style: followF),
                                const SizedBox(
                                  width: 15,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.comment,
                                    size: 18,
                                    color: Colors.grey[700],
                                  ),
                                  onPressed: () {
                                    commentSheet(context, tweetdata[index].id,
                                        tweetdata[index]['tokenId']);
                                  },
                                ),
                                Text(tweetdata[index]['comments'].toString(),
                                    style: followF),
                                const SizedBox(
                                  width: 15,
                                ),
                                IconButton(
                                  icon: Icon(
                                    EvaIcons.flip,
                                    size: 18,
                                    color: isRetweeted
                                        ? Color.fromARGB(255, 29, 212, 38)
                                        : Colors.grey[700],
                                  ),
                                  onPressed: () {
                                    if (isRetweeted) {
                                      authClass.retweetFuction(
                                          tweetdata[index].id,
                                          tweetdata[index]['username'],
                                          tweetdata[index]['tokenId'],
                                          "");
                                    } else {
                                      retweetSheet(
                                        context,
                                        tweetdata[index].id,
                                        tweetdata[index]['username'],
                                        tweetdata[index]['tokenId'],
                                      );
                                    }
                                  },
                                ),
                                Text(
                                  tweetdata[index]['retweetCount']
                                      .length
                                      .toString(),
                                  style: followF,
                                ),
                              ],
                            ),
                          )
                        ]),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ));
  }
}
