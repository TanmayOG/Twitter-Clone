// ignore_for_file: unused_local_variable, unrelated_type_equality_checks, await_only_futures, must_be_immutable

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/Constants/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twitter_clone/Screen/Profile/edit_profile.dart';
import 'package:twitter_clone/Widgets/app_provider.dart';
import 'package:twitter_clone/Widgets/font.dart';
import 'package:twitter_clone/Widgets/sheetHelper.dart';
import 'package:twitter_clone/Widgets/full_image.dart';

import '../../Widgets/imageswipe.dart';
import 'otherProfile.dart';

class UserProfilePage extends StatefulWidget {
  String? id;
  UserProfilePage({Key? key, this.id}) : super(key: key);

  @override
  State<UserProfilePage> createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage>
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
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.42,
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                var dat = userProvider.date;
                if (dat == null) {
                  return Center(
                    child: Container(),
                  );
                } else {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                        id: userProvider.cover,
                                      )));
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.13,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              image: DecorationImage(
                                  image: NetworkImage(userProvider.cover ?? ''),
                                  fit: BoxFit.cover)),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.08,
                        left: MediaQuery.of(context).size.width * 0.05,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                            id: userProvider.profilePhotoUrl,
                                          )));
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 35,
                              backgroundImage: NetworkImage(
                                  '${userProvider.profilePhotoUrl}'),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.07,
                        top: MediaQuery.of(context).size.height * 0.18,
                        child: Text(
                            userProvider.username.toString().toTitleCase(),
                            style: usernamePF),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.6,
                        top: MediaQuery.of(context).size.height * 0.17,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextButton(
                            // color: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfile(
                                    displayName: userProvider.username ?? '',
                                    bio: userProvider.bio ?? '',
                                    image: userProvider.profilePhotoUrl,
                                    cover: userProvider.cover,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Edit Profile',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.04,
                        top: MediaQuery.of(context).size.height * 0.22,
                        child: Text('${userProvider.email}', style: emailPF),
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
                              'Joined ${DateFormat('MMMM yyyy').format(dat.toDate())}',
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
                        child: Row(
                          children: [
                            Text('${userProvider.follower}  Followers',
                                style: followPF),
                            const SizedBox(
                              width: 10,
                            ),
                            Text('${userProvider.following}  Following',
                                style: followPF),
                          ],
                        ),
                      ),
                      userProvider.bio == null
                          ? Container()
                          : Positioned(
                              left: MediaQuery.of(context).size.width * 0.04,
                              right: MediaQuery.of(context).size.width * 0.04,
                              top: MediaQuery.of(context).size.height * 0.34,
                              child: HashtagText(
                                text: "${userProvider.bio}",
                              ),
                            ),
                    ],
                  );
                }
              },
            ));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProvider checker = Provider.of<UserProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LiquidPullToRefresh(
          color: Colors.blue,
          showChildOpacityTransition: false,
          animSpeedFactor: 3,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2)).then((value) {
              setState(() {
                checker.getUserData();
              });
            });
          },
          springAnimationDurationInMilliseconds: 700,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                createSilverAppBar1(),
              ];
            },
            body: Column(
              children: [
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
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black),
                      indicatorColor: Colors.transparent,

                      tabs: const [
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
                                  .where('creator',
                                      isEqualTo: FirebaseAuth
                                          .instance.currentUser!.uid)
                                  .snapshots(includeMetadataChanges: true),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return const Text("Something went wrong");
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
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
                                      var tweetdata = snapshot.data!.docs;
                                      String tweets =
                                          tweetdata[index]['tweets'];
                                      var isLike = tweetdata[index]['likes']
                                          .contains(FirebaseAuth
                                              .instance.currentUser!.uid);
                                      debugPrint('Likes  $isLike');
                                      var isRetweeted = tweetdata[index]
                                              ['retweetCount']
                                          .contains(FirebaseAuth
                                              .instance.currentUser!.uid);
                                      var imageList = tweetdata[index]['image'];
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
                                                        padding:
                                                            const EdgeInsets
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
                                                                      [
                                                                      'creator'],
                                                                  token: tweetdata[
                                                                          index]
                                                                      [
                                                                      'tokenId'],
                                                                ),
                                                              ),
                                                            ).then((value) {
                                                              debugPrint(
                                                                  tweetdata[
                                                                          index]
                                                                      [
                                                                      'creator']);
                                                            });
                                                          },
                                                          child: Text(
                                                              tweetdata[index][
                                                                      'username']
                                                                  .toString()
                                                                  .toTitleCase(),
                                                              style: usernameF),
                                                        ),
                                                      ),
                                                      Text(
                                                          timeago.format(
                                                              tweetdata[index][
                                                                      'timestamp']
                                                                  .toDate()),
                                                          style: timeF),
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
                                                          tweetdata[index][
                                                                  'retweetCount']
                                                              .length
                                                              .toString(),
                                                        );
                                                      },
                                                      child: HashtagText(
                                                        text: tweets,
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
                                                              tweetdata[index]
                                                                  .id,
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
                                                                    builder:
                                                                        (_) {
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
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      tweetdata[index].id,
                                                      tweetdata[index]
                                                          ['tokenId']);
                                                },
                                              ),
                                              Text(
                                                tweetdata[index]['likes']
                                                    .length
                                                    .toString(),
                                                style: followF,
                                              ),
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
                                                      tweetdata[index]
                                                          ['tokenId'],
                                                    );
                                                  }
                                                },
                                              ),
                                              Text(
                                                  tweetdata[index]
                                                          ["retweetCount"]
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
                                  return Center(
                                      child: Text('${snapshot.error}'));
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
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('retweets')
                                  .snapshots(includeMetadataChanges: true),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return const Text("Something went wrong");
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CupertinoActivityIndicator());
                                }
                                if (snapshot.hasData == null) {
                                  return const Center(
                                    child: Text('No Retweets'),
                                  );
                                }

                                if (snapshot.hasData) {
                                  var tweetdata = snapshot.data!.docs;
                                  print('users');
                                  print(tweetdata.length);

                                  return ListView.builder(
                                      physics: const ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      // duplicate the listview

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
                                            Divider(
                                              color: Colors.grey[600],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0),
                                              child: Row(
                                                children: [
                                                  const Text('retweeted',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold)),
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
                                                  style: usernameF),
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
                                                        (data.data()
                                                                    as dynamic)[
                                                                'quote']
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 13),
                                                      ),
                                                    ),
                                                  ),
                                            StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('posts')
                                                    .where('timestamp',
                                                        isEqualTo: (data.data()
                                                            as dynamic)['date'])
                                                    .snapshots(),
                                                builder: (context,
                                                    AsyncSnapshot snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
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
                                                    itemCount:
                                                        tweetdata2.length,
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
                                                      var isLike = tweetdata[
                                                              index]['likes']
                                                          .contains(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid);
                                                      var isRetweeted = tweetdata[
                                                                  index]
                                                              ['retweetCount']
                                                          .contains(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid);
                                                      var post = firestore
                                                          .collection('posts')
                                                          .doc(tweetdata[index]
                                                              .id);
                                                      var retweetdata = post
                                                          .collection(
                                                              'retweets')
                                                          .where('userId',
                                                              isEqualTo:
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid)
                                                          .get();
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  left: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.05,
                                                                ),
                                                              ),

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
                                                                          .circular(
                                                                              8),
                                                                  border:
                                                                      const Border(
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
                                                                child: Column(
                                                                  children: [
                                                                    ListTile(
                                                                        title: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment
                                                                                .start,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(),
                                                                                    child: GestureDetector(
                                                                                      onTap: () {
                                                                                        Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                            builder: (context) => ProfilePage(
                                                                                              id: tweetdata[index]['creator'],
                                                                                              token: tweetdata[index]['tokenId'],
                                                                                            ),
                                                                                          ),
                                                                                        ).then((value) {
                                                                                          debugPrint(tweetdata[index]['creator']);
                                                                                        });
                                                                                      },
                                                                                      child: Text(tweetdata[index]['username'].toString().toTitleCase(), style: usernameF),
                                                                                    ),
                                                                                  ),
                                                                                  Text(timeago.format(tweetdata[index]['timestamp'].toDate()), style: timeF),
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
                                                                                      tweetdata[index]['image'],
                                                                                      tweetdata[index]['likes'].length.toString(),
                                                                                      tweetdata[index]['timestamp'],
                                                                                      tweetdata[index].id,
                                                                                      tweetdata[index]['retweetCount'].length.toString(),
                                                                                    );
                                                                                  },
                                                                                  child: HashtagText(text: tweets)),
                                                                              const SizedBox(
                                                                                height: 10,
                                                                              ),
                                                                              imageList.length == 0
                                                                                  ? Container()
                                                                                  : GestureDetector(
                                                                                      onTap: () {
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
                                                                                      onLongPress: () {
                                                                                        Navigator.push(context, MaterialPageRoute(builder: (_) {
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
                                                                        subtitle:
                                                                            Text(
                                                                          timeago
                                                                              .format(tweetdata[index]['timestamp'].toDate()),
                                                                          style:
                                                                              timeF,
                                                                        ),
                                                                        leading:
                                                                            CircleAvatar(
                                                                          backgroundImage:
                                                                              NetworkImage(tweetdata[index]['userImage'] as String),
                                                                        )),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: MediaQuery.of(context).size.width *
                                                                              0.15),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          IconButton(
                                                                            icon: isLike
                                                                                ? const Icon(
                                                                                    CupertinoIcons.heart_circle_fill,
                                                                                    size: 16,
                                                                                    color: Colors.red,
                                                                                  )
                                                                                : Icon(
                                                                                    Icons.favorite_border_outlined,
                                                                                    size: 16,
                                                                                    color: Colors.grey[500],
                                                                                  ),
                                                                            onPressed:
                                                                                () {
                                                                              authClass.addLikes(FirebaseAuth.instance.currentUser!.uid, tweetdata[index].id, tweetdata[index]['tokenId']);
                                                                            },
                                                                          ),
                                                                          Text(tweetdata[index]['likes']
                                                                              .length
                                                                              .toString()),
                                                                          const SizedBox(
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          IconButton(
                                                                            icon:
                                                                                Icon(
                                                                              Icons.comment,
                                                                              size: 16,
                                                                              color: Colors.grey[700],
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              commentSheet(context, tweetdata[index].id, tweetdata[index]['tokenId']);
                                                                            },
                                                                          ),
                                                                          Text(tweetdata[index]['comments']
                                                                              .toString()),
                                                                          const SizedBox(
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          IconButton(
                                                                            icon:
                                                                                Icon(
                                                                              EvaIcons.flip,
                                                                              size: 16,
                                                                              color: isRetweeted ? const Color.fromARGB(255, 29, 212, 38) : Colors.grey[700],
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              if (isRetweeted) {
                                                                                authClass.retweetFuction(tweetdata[index].id, tweetdata[index]['username'], tweetdata[index]['tokenId'], "");
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
                                                                          Text(tweetdata[index]["retweetCount"]
                                                                              .length
                                                                              .toString()),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),

                                                              // Divider(
                                                              //   color:
                                                              //       Colors.grey[300],
                                                              // )
                                                            ]),
                                                      );
                                                    },
                                                  );
                                                }),
                                          ],
                                        );
                                      });
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('${snapshot.error}'));
                                } else {
                                  return Center(
                                      child: CupertinoActivityIndicator());
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
      ),
    );
  }
}
