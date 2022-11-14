// ignore_for_file: unused_local_variable, unrelated_type_equality_checks, await_only_futures

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/Constants/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twitter_clone/Screen/Chats/chat_room.dart';
import 'package:twitter_clone/Widgets/app_provider.dart';
import 'package:twitter_clone/Widgets/font.dart';
import 'package:twitter_clone/Widgets/full_image.dart';
import 'package:twitter_clone/Widgets/imageswipe.dart';

import '../../Widgets/sheetHelper.dart';

class ProfilePage extends StatefulWidget {
  final String? id;
  final String? token;

  ProfilePage({Key? key, this.token, this.id}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  bool isReadmore = false;
  var follower = 0;
  var following = 0;
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  SliverAppBar createSilverAppBar1() {
    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: MediaQuery.of(context).size.height * 0.45,
      floating: true,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: const Center(child: CupertinoActivityIndicator()),
                );
              }
              var data = snapshot.data! as dynamic;
              var date = data['date'].toDate();

              return SizedBox(
                height: data['bio'] != ""
                    ? MediaQuery.of(context).size.height * 0.45
                    : MediaQuery.of(context).size.height * 0.35,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                      id: data['cover'],
                                    )));
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.13,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            image: DecorationImage(
                                image: NetworkImage(data['cover'] ?? ''),
                                fit: BoxFit.cover)),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.08,
                      left: MediaQuery.of(context).size.width * 0.05,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 32,
                          backgroundImage: NetworkImage(data['image']),
                        ),
                      ),
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.06,
                      top: MediaQuery.of(context).size.height * 0.18,
                      child: Text(data['username'].toString().toTitleCase(),
                          style: usernamePF),
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.68,
                      top: MediaQuery.of(context).size.height * 0.18,
                      child: StreamBuilder(
                          stream: authClass.isFollowing(
                              FirebaseAuth.instance.currentUser!.uid,
                              widget.id),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.hasError.toString()),
                              );
                            }
                            if (snapshot.hasData) {
                              var isFollow = snapshot.data;
                              return Row(
                                children: [
                                  if (FirebaseAuth.instance.currentUser!.uid !=
                                          widget.id &&
                                      isFollow == false)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        primary: Colors.transparent,
                                        side: const BorderSide(
                                            color: Colors.lightBlue),
                                      ),
                                      onPressed: () {
                                        authClass.followUser(
                                          widget.id,
                                          data['tokenId'],
                                        );
                                      },
                                      child: const Text(
                                        'Follow',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  else if (FirebaseAuth
                                              .instance.currentUser!.uid !=
                                          widget.id &&
                                      isFollow == true)
                                    Column(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              primary: Colors.lightBlue),
                                          onPressed: () {
                                            authClass.unFollowUser(widget.id);
                                          },
                                          child: const Text(
                                            'Following',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              elevation: 2,
                                              primary: Colors.white24),
                                          onPressed: () async {
                                            debugPrint(
                                                data['tokenId'].toString());
                                            var chatRoom = await authClass
                                                .getChatRoomMOdel(widget.id)
                                                .then((chatRoom) {
                                              if (chatRoom != null &&
                                                  data['tokenId'] != null) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatRoomScreen(
                                                              chatModel:
                                                                  chatRoom,
                                                              chatId: data[
                                                                  'tokenId'],
                                                              tokenId:
                                                                  widget.token,
                                                              otherId:
                                                                  widget.id,
                                                            )));
                                              }
                                            });
                                          },
                                          child: const Text(
                                            'Message',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  else if (FirebaseAuth
                                          .instance.currentUser!.uid ==
                                      widget.id)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 2, primary: Colors.white),
                                      onPressed: () {},
                                      child: const Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }
                            return Container();
                          }),
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.04,
                      top: MediaQuery.of(context).size.height * 0.22,
                      child: Text(data['email'], style: emailPF),
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.04,
                      top: MediaQuery.of(context).size.height * 0.26,
                      child: Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Joined ${DateFormat('MMMM yyyy').format(date)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // TODO: FOLLOWER LIST UPDATE

                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.04,
                      top: MediaQuery.of(context).size.height * 0.3,
                      child: Row(children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.04,
                        ),
                        Text(data['following'].toString(), style: followPF),
                        const Text("  following", style: followPF),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.04,
                        ),
                        Text(data['follower'].toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const Text("  followers", style: followPF),
                      ]),
                    ),

                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.04,
                      top: MediaQuery.of(context).size.height * 0.38,
                      child: Text(data['bio'] ?? '', style: bioF),
                    ),
                  ],
                ),
              );
            });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProvider checker = Provider.of<UserProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              createSilverAppBar1(),
            ];
          },
          body: Column(
            children: [
              // Tab bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20)),
                  child: TabBar(
                    controller: _tabController,
                    unselectedLabelColor: Colors.grey,
                    // padding: EdgeInsets.only(bottom: 10),
                    labelColor: Colors.white,
                    // selectedLabelColor: Colors.blue,
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                    indicatorColor: Colors.transparent,

                    tabs: [
                      Tab(
                        text: 'Tweets',
                      ),
                      Tab(
                        text: 'Retweets',
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .where('creator', isEqualTo: widget.id)
                                .snapshots(includeMetadataChanges: true),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return const Text("Something went wrong");
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: const Center(
                                      child: CupertinoActivityIndicator()),
                                );
                              }

                              if (snapshot.hasData) {
                                return ListView.builder(
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        child: const Center(
                                            child:
                                                CupertinoActivityIndicator()),
                                      );
                                    }
                                    var tweetdata = snapshot.data!.docs;
                                    String tweets = tweetdata[index]['tweets'];
                                    var isLike = tweetdata[index]['likes']
                                        .contains(userId);
                                    var imageList = tweetdata[index]['image'];
                                    var isRetweeted = tweetdata[index]
                                            ['retweetCount']
                                        .contains(userId);
                                    var post = firestore
                                        .collection('posts')
                                        .doc(tweetdata[index].id);
                                    var retweetdata = post
                                        .collection('retweets')
                                        .where('userId',
                                            isEqualTo: FirebaseAuth
                                                .instance.currentUser!.uid)
                                        .get();
                                    return Column(children: [
                                      ListTile(
                                          title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .only(),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      ProfilePage(
                                                                id: tweetdata[
                                                                        index]
                                                                    ['creator'],
                                                                token: tweetdata[
                                                                        index]
                                                                    ['tokenId'],
                                                              ),
                                                            ),
                                                          ).then((value) {
                                                            debugPrint(
                                                                tweetdata[index]
                                                                    [
                                                                    'creator']);
                                                          });
                                                        },
                                                        child: Text(
                                                            tweetdata[index]
                                                                    ['username']
                                                                .toString()
                                                                .toTitleCase(),
                                                            style: usernameF),
                                                      ),
                                                    ),
                                                    Text(
                                                      timeago.format(
                                                          tweetdata[index]
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
                                                        tweetdata[index]
                                                                ['retweetCount']
                                                            .length
                                                            .toString(),
                                                      );
                                                    },
                                                    child: Text(
                                                      tweets,
                                                      style: captionF,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                imageList.length == 0
                                                    ? Container()
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
                                                            height: 260,
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
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ]),
                                          subtitle: Text(
                                              timeago.format(tweetdata[index]
                                                      ['timestamp']
                                                  .toDate()),
                                              style: timeF),
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                tweetdata[index]['userImage']
                                                    as String),
                                          )),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: isLike
                                                  ? const Icon(
                                                      CupertinoIcons
                                                          .heart_circle_fill,
                                                      size: 16,
                                                      color: Colors.red,
                                                    )
                                                  : Icon(
                                                      Icons
                                                          .favorite_border_outlined,
                                                      size: 16,
                                                      color: Colors.grey[500],
                                                    ),
                                              onPressed: () {
                                                authClass.addLikes(
                                                    widget.id,
                                                    tweetdata[index].id,
                                                    tweetdata[index]
                                                        ['tokenId']);
                                              },
                                            ),
                                            Text(
                                                tweetdata[index]['likes']
                                                    .length
                                                    .toString(),
                                                style: followF),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.comment,
                                                size: 16,
                                                color: Colors.grey[700],
                                              ),
                                              onPressed: () {
                                                commentSheet(
                                                    context,
                                                    tweetdata[index].id,
                                                    tweetdata[index]
                                                        ['tokenId']);
                                              },
                                            ),
                                            Text(
                                                tweetdata[index]['comments']
                                                    .toString(),
                                                style: followF),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                EvaIcons.flip,
                                                size: 16,
                                                color: isRetweeted
                                                    ? const Color.fromARGB(
                                                        255, 29, 212, 38)
                                                    : Colors.grey[700],
                                              ),
                                              onPressed: () {
                                                if (isRetweeted) {
                                                  authClass.retweetFuction(
                                                      tweetdata[index].id,
                                                      tweetdata[index]
                                                          ['username'],
                                                      tweetdata[index]
                                                          ['tokenId'],
                                                      "");
                                                } else {
                                                  retweetSheet(
                                                    context,
                                                    tweetdata[index].id,
                                                    tweetdata[index]
                                                        ['username'],
                                                    tweetdata[index]['tokenId'],
                                                  );
                                                }
                                              },
                                            ),
                                            Text(
                                                tweetdata[index]["retweetCount"]
                                                    .length
                                                    .toString(),
                                                style: followF),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.grey[300],
                                      )
                                    ]);
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return Center(child: Text('${snapshot.error}'));
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            }),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.id)
                                .collection('retweets')
                                .snapshots(includeMetadataChanges: true),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return const Text("Something went wrong");
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: const Center(
                                      child: CupertinoActivityIndicator()),
                                );
                              }
                              if (snapshot.hasData == null) {
                                return const Center(
                                  child: Text('No Retweets'),
                                );
                              }

                              if (snapshot.hasData) {
                                var tweetdata = snapshot.data!.docs;
                                return ListView.builder(
                                    physics: const ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: tweetdata.length,
                                    itemBuilder: (context, index) {
                                      var data = snapshot.data!.docs[index];

                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: Text('No Retweets'),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return const Center(
                                          child: Text('Something went wrong'),
                                        );
                                      }
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Row(
                                              children: [
                                                const Text('retweeted'),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Icon(
                                                  EvaIcons.flip,
                                                  size: 15,
                                                  color: Colors.grey[500],
                                                ),
                                              ],
                                            ),
                                          ),
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  checker.profilePhotoUrl
                                                      as String),
                                            ),
                                            title: Text(
                                              checker.username as String,
                                              style: usernameF,
                                            ),
                                          ),
                                          (data.data() as dynamic)['quote'] ==
                                                  ""
                                              ? Container()
                                              : ListTile(
                                                  title: Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    constraints: BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.65),
                                                    child: Text(
                                                      (data.data() as dynamic)[
                                                              'quote']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                ),
                                          StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .where('timestamp',
                                                      isEqualTo: (data.data()
                                                          as dynamic)['date'])
                                                  .snapshots(),
                                              builder: (context,
                                                  AsyncSnapshot snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child:
                                                          CupertinoActivityIndicator());
                                                }
                                                var tweetdata2 =
                                                    snapshot.data!.docs;
                                                return ListView.builder(
                                                  physics:
                                                      const ClampingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: tweetdata2.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var tweetdata =
                                                        snapshot.data!.docs;
                                                    String tweets =
                                                        tweetdata[index]
                                                            ['tweets'];
                                                    var imageList =
                                                        tweetdata[index]
                                                            ['image'];
                                                    var isLike =
                                                        tweetdata[index]
                                                                ['likes']
                                                            .contains(userId);
                                                    var isRetweeted =
                                                        tweetdata[index]
                                                                ['retweetCount']
                                                            .contains(userId);
                                                    var post = firestore
                                                        .collection('posts')
                                                        .doc(tweetdata[index]
                                                            .id);

                                                    return Column(children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.9,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: const Border(
                                                            top: BorderSide(
                                                                color: Colors
                                                                    .white24),
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .white24),
                                                            left: BorderSide(
                                                                color: Colors
                                                                    .white24),
                                                            right: BorderSide(
                                                                color: Colors
                                                                    .white24),
                                                          ),
                                                        ),
                                                        child: ListTile(
                                                            title: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: MediaQuery.of(context).size.height *
                                                                            0.026),
                                                                    child: Text(
                                                                        tweetdata[index]['username']
                                                                            .toString()
                                                                            .toTitleCase(),
                                                                        style:
                                                                            usernameF),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        showDetail(
                                                                            context,
                                                                            tweetdata[index]['creator'],
                                                                            tweetdata[index]['userImage'],
                                                                            tweetdata[index]['username'],
                                                                            tweets,
                                                                            tweetdata[index]['tokenId'],
                                                                            tweetdata[index]['image'],
                                                                            tweetdata[index]['likes'].length.toString(),
                                                                            tweetdata[index]['timestamp'],
                                                                            tweetdata[index].id,
                                                                            tweetdata[index]['retweetCount'].length.toString());
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        tweets,
                                                                        style:
                                                                            captionF,
                                                                        maxLines:
                                                                            3,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      )),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  imageList.length ==
                                                                          0
                                                                      ? Container()
                                                                      : GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            showDetail(
                                                                              context,
                                                                              tweetdata[index]['creator'],
                                                                              tweetdata[index]['userImage'],
                                                                              tweetdata[index]['username'],
                                                                              tweets,
                                                                              tweetdata[index]['tokenId'],
                                                                              tweetdata[index]['image'],
                                                                              tweetdata[index]['likes'].length.toString(),
                                                                              tweetdata[index]['timestamp'],
                                                                              tweetdata[index].id,
                                                                              tweetdata[index]['retweetCount'].length.toString(),
                                                                            );
                                                                          },
                                                                          onLongPress:
                                                                              () {
                                                                            Navigator.push(context,
                                                                                MaterialPageRoute(builder: (_) {
                                                                              return DetailScreen(
                                                                                id: tweetdata[index]['image'],
                                                                              );
                                                                            }));
                                                                          },
                                                                          child: SizedBox(
                                                                              height: 260,
                                                                              child: ImageSwipe(
                                                                                height: MediaQuery.of(context).size.height * 0.3,
                                                                                imageList: imageList,
                                                                              )),
                                                                        ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                ]),
                                                            subtitle: Text(
                                                                timeago.format(
                                                                    tweetdata[index]
                                                                            [
                                                                            'timestamp']
                                                                        .toDate()),
                                                                style: timeF),
                                                            leading:
                                                                CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(tweetdata[
                                                                              index]
                                                                          [
                                                                          'userImage']
                                                                      as String),
                                                            )),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.15),
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                              icon: isLike
                                                                  ? const Icon(
                                                                      CupertinoIcons
                                                                          .heart_circle_fill,
                                                                      size: 16,
                                                                      color: Colors
                                                                          .red,
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .favorite_border_outlined,
                                                                      size: 16,
                                                                      color: Colors
                                                                              .grey[
                                                                          500],
                                                                    ),
                                                              onPressed: () {
                                                                authClass.addLikes(
                                                                    widget.id,
                                                                    tweetdata[
                                                                            index]
                                                                        .id,
                                                                    tweetdata[
                                                                            index]
                                                                        [
                                                                        'tokenId']);
                                                              },
                                                            ),
                                                            Text(
                                                                tweetdata[index]
                                                                        [
                                                                        'likes']
                                                                    .length
                                                                    .toString(),
                                                                style: followF),
                                                            const SizedBox(
                                                              width: 15,
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.comment,
                                                                size: 16,
                                                                color: Colors
                                                                    .grey[700],
                                                              ),
                                                              onPressed: () {
                                                                commentSheet(
                                                                    context,
                                                                    tweetdata[
                                                                            index]
                                                                        .id,
                                                                    tweetdata[
                                                                            index]
                                                                        [
                                                                        'tokenId']);
                                                              },
                                                            ),
                                                            Text(
                                                                tweetdata[index]
                                                                        [
                                                                        'comments']
                                                                    .toString(),
                                                                style: followF),
                                                            const SizedBox(
                                                              width: 15,
                                                            ),
                                                            RotatedBox(
                                                              quarterTurns: 3,
                                                              child: IconButton(
                                                                icon: Icon(
                                                                  CupertinoIcons
                                                                      .repeat,
                                                                  size: 16,
                                                                  color: isRetweeted
                                                                      ? const Color
                                                                              .fromARGB(
                                                                          255,
                                                                          29,
                                                                          212,
                                                                          38)
                                                                      : Colors.grey[
                                                                          700],
                                                                ),
                                                                onPressed: () {
                                                                  if (isRetweeted) {
                                                                    authClass.retweetFuction(
                                                                        tweetdata[index]
                                                                            .id,
                                                                        tweetdata[index]
                                                                            [
                                                                            'username'],
                                                                        tweetdata[index]
                                                                            [
                                                                            'tokenId'],
                                                                        "");
                                                                  } else {
                                                                    retweetSheet(
                                                                        tweetdata[index]
                                                                            .id,
                                                                        tweetdata[index]
                                                                            [
                                                                            'username'],
                                                                        tweetdata[index]
                                                                            [
                                                                            'tokenId'],
                                                                        "");
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            Text(
                                                                tweetdata[index]
                                                                        [
                                                                        "retweetCount"]
                                                                    .length
                                                                    .toString(),
                                                                style: followF),
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(
                                                        color: Colors.grey[300],
                                                      )
                                                    ]);
                                                  },
                                                );
                                              }),
                                        ],
                                      );
                                    });
                              } else if (snapshot.hasError) {
                                return Center(child: Text('${snapshot.error}'));
                              } else {
                                return Center();
                              }
                            }),
                      ],
                    ),
                  )
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
