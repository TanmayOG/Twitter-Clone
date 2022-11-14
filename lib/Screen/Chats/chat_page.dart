// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twitter_clone/Constants/constants.dart';
import 'package:twitter_clone/Model/chat_model.dart';
import 'package:twitter_clone/Widgets/font.dart';

import 'chat_room.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: const Text('Messages',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.black,
        body: StreamBuilder(
          stream: firestore
              .collection("chatrooms")
              .where("participants.$userId", isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            print('DATA:::${snapshot.hasData}');
            if (snapshot.hasData == true) {
              QuerySnapshot snap = snapshot.data as QuerySnapshot;
              print('DATA:::${snap.docs.length}');
              if (snap.docs.length == 0) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Your chat list is empty',
                        style: usernamePF,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Once you start a new conversation, you see it will appear here',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return ListView.builder(
                  itemCount: snap.docs.length,
                  itemBuilder: (context, index) {
                    print(snap.docs.length);
                    ChatModel chat = ChatModel.fromMap(
                        snap.docs[index].data() as Map<String, dynamic>);
                    Map<String, dynamic> participants = chat.participants!;
                    List<String> keys = participants.keys.toList();
                    keys.remove(userId);
                    if (snap.docs.length == 0) {
                      return Center(
                        child: Text('No chats yet'),
                      );
                    }

                    return StreamBuilder(
                      stream: firestore
                          .collection("users")
                          .doc(keys[0])
                          .snapshots(),
                      builder: (context, snapshot) {
                        print('DATA:::${snapshot.data}');
                        if (snapshot.hasData == true) {
                          var userData = snapshot.data as DocumentSnapshot;

                          return ListTile(
                            onTap: () async {
                              var chatRoom =
                                  await authClass.getChatRoomMOdel(userData.id);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                            chatModel: chatRoom,
                                            otherId: userData.id,
                                          )));
                            },
                            leading: CircleAvatar(
                              radius: 23,
                              backgroundImage: NetworkImage(userData['image']),
                            ),
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                userData['username'],
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, top: 1),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.69),
                                    child: Text(
                                      chat.lastMessage as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, top: 4),
                                  child: Text(
                                    timeago
                                        .format(chat.lastMessageTime.toDate()),
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey[300]),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: const CupertinoActivityIndicator(),
                          );
                        } else {
                          return const Center(
                            child: const CupertinoActivityIndicator(),
                          );
                        }
                      },
                    );
                  },
                );
              }
            } else if (snapshot.hasData == null) {
              return const Center(child: Text("No data"));
            } else {
              return const Center(child: const CupertinoActivityIndicator());
            }
          },
        ));
  }
}
