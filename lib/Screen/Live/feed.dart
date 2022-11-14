import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/Constants/constants.dart';
import 'package:twitter_clone/Screen/Live/live.dart';
import 'package:twitter_clone/Screen/Live/liveScreen.dart';
import 'package:twitter_clone/Widgets/app_provider.dart';
import 'package:twitter_clone/Widgets/font.dart';

class LiveFeed extends StatefulWidget {
  const LiveFeed({Key? key}) : super(key: key);

  @override
  State<LiveFeed> createState() => _LiveFeedState();
}

class _LiveFeedState extends State<LiveFeed> {
  @override
  Widget build(BuildContext context) {
    final UserProvider user = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Live Space', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              width: 10,
            ),
            Icon(
              Iconsax.microphone,
            ),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  fullscreenDialog: true,
                  builder: (context) {
                    return const GoLive();
                  }));
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Iconsax.microphone,
          color: Colors.white,
        ),
      ),
      body: ListView(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('live').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return const Center(
                  child: const CircularProgressIndicator(),
                );
              }
              if (snapshot.data!.docs.length == 0) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.26,
                    ),
                    const Center(
                      child: Text(
                        'No Live Space Available',
                        style: usernamePF,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: const Text(
                          'You can create a live space by clicking on the Mic button',
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    print(
                        'LENGHT ${snapshot.data!.docs.length}  ${snapshot.data!.docs.isEmpty}');
                    final liveData = snapshot.data!.docs[index] as dynamic;
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No Live Streams', style: usernamePF),
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                fullscreenDialog: true,
                                builder: (context) {
                                  return LiveScreen(
                                    cast: false,
                                    channelName: liveData.data()['channelId'],
                                  );
                                }));
                      },
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          ListTile(
                              title: Stack(
                            children: [
                              Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            '${liveData.data()['image']}'),
                                        fit: BoxFit.cover,
                                      ))),
                              Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 30,
                                  width: 70,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Lottie.network(
                                            "https://assets5.lottiefiles.com/packages/lf20_tlnwbaep.json"),
                                        const Text(
                                          "Live",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      alignment: Alignment.topRight,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      height: 30,
                                      width: 100,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Iconsax.eye4,
                                              size: 18,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '${liveData['viewer']}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              // title: Text(liveData.data()['title'],
                              title: Text(liveData.data()['title'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              subtitle: Row(
                                children: [
                                  const Icon(
                                    Iconsax.user_square,
                                    size: 22,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(liveData['username']),
                                ],
                              ),
                              trailing: Text(
                                  'Started ${timeAgo.format(liveData['start']?.toDate())}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const Divider(
                            color: Colors.white,
                          ),
                        ],
                      ),
                    );
                  });
            },
          )
        ],
      ),
    );
  }
}
