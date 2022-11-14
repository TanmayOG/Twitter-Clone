// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/Constants/constants.dart';
import 'package:twitter_clone/Model/chat_model.dart';
import 'package:twitter_clone/Model/message_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twitter_clone/Widgets/app_provider.dart';
import 'package:twitter_clone/main.dart';

class ChatRoomScreen extends StatefulWidget {
  final otherId;
  final chatId;
  final tokenId;
  final ChatModel? chatModel;

  const ChatRoomScreen(
      {Key? key, this.otherId, this.chatModel, this.chatId, this.tokenId})
      : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with WidgetsBindingObserver {
  TextEditingController message = TextEditingController();
  var tokenId;
  Radius messageRadius = const Radius.circular(10);
  var tk;
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: StreamBuilder(
              stream:
                  firestore.collection('users').doc(widget.otherId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                var data = snapshot.data as dynamic;
                tk = data['tokenId'];
                return Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(data['image']),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Text(data['username'] ?? '',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: Column(
              children: [
                Divider(
                  color: Colors.grey[800],
                  thickness: 0.5,
                  indent: 10.0,
                  endIndent: 10.0,
                ),
                Expanded(
                    child: Container(
                  child: StreamBuilder(
                    stream: firestore
                        .collection('chatrooms')
                        .doc(widget.chatModel!.chatRoomId)
                        .collection('messages')
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      debugPrint(snapshot.data.toString());
                      QuerySnapshot snap = snapshot.data as QuerySnapshot;
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {}
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            reverse: true,
                            itemCount: snap.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel messageModel = MessageModel.fromMap(
                                  snap.docs[index].data()
                                      as Map<String, dynamic>);
                              print(snap.docs[index]['seen'].toString());
                              // when chat load set seen to true

                              if (messageModel.sender != userId) {
                                if (snap.docs[index]['seen'] == false) {
                                  firestore
                                      .collection('chatrooms')
                                      .doc(widget.chatModel!.chatRoomId)
                                      .collection('messages')
                                      .doc(snap.docs[index].id)
                                      .update({
                                    'seen': true,
                                  });
                                }
                              } else {
                                print("receiver");
                              }

                              return Column(
                                crossAxisAlignment:
                                    messageModel.sender == userId
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        messageModel.sender == userId
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomRight:
                                                messageModel.sender != userId
                                                    ? messageRadius
                                                    : const Radius.circular(0),
                                            topRight: messageRadius,
                                            bottomLeft: messageRadius,
                                            topLeft:
                                                messageModel.sender == userId
                                                    ? messageRadius
                                                    : const Radius.circular(0),
                                          ),
                                          color: messageModel.sender == userId
                                              ? Colors.blue
                                              : Colors.grey[900],
                                        ),
                                        margin: EdgeInsets.symmetric(
                                            vertical: size.height * 0.005),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.height * 0.015,
                                            vertical: size.height * 0.01),
                                        child: Column(
                                          crossAxisAlignment:
                                              messageModel.sender == userId
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              children: [
                                                GestureDetector(
                                                  onLongPress: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Delete this chat?'),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  'Cancel'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            // ignore: deprecated_member_use
                                                            TextButton(
                                                              child: const Text(
                                                                  'Delete'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();

                                                                deleteMessgae(
                                                                    messageModel
                                                                        .messageId);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Text(
                                                    messageModel.text as String,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Text(
                                            //   timeago.format(messageModel.time!),
                                            //   style: const TextStyle(
                                            //       fontSize: 10,
                                            //       color: Colors.white70),
                                            // )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        messageModel.sender == userId
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    children: [
                                      messageModel.sender != userId
                                          ? Container()
                                          : Icon(
                                              Icons.done_all,
                                              size: 13,
                                              color: messageModel.seen == true
                                                  ? Colors.blue
                                                  : Colors.white,
                                            ),
                                      SizedBox(width: size.height * 0.01),
                                      Text(
                                        timeago.format(messageModel.time!),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70),
                                      ),
                                    ],
                                  )
                                  // Icon(
                                  //   Icons.done_all,
                                  //   size: 13,
                                  //   color: messageModel.seen == true
                                  //       ? Colors.green
                                  //       : Colors.white,
                                  // )
                                ],
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text('{{error}}'),
                          );
                        } else {
                          return const Center(
                            child: Text('{{error}}'),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                )),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  color: Colors.black,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: message,
                            maxLines: null,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                                hintText: 'Type a message',
                                helperStyle:
                                    const TextStyle(color: Colors.white),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      var doc = await firestore
                                          .collection('users')
                                          .doc(widget.otherId)
                                          .get();
                                      var token = doc.data()!['tokenId'];
                                      sendMessage(token, userProvider.username);
                                      print('token $token');
                                    },
                                    icon: const Icon(Icons.send_sharp))),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  deleteMessgae(msgid) async {
    await firestore
        .collection('chatrooms')
        .doc(widget.chatModel!.chatRoomId)
        .collection('messages')
        .doc(msgid)
        .delete();
  }

  sendMessage(otherToken, name) async {
    String msg = message.text.trim();
    debugPrint(widget.tokenId.toString());

    if (msg != '') {
      MessageModel messageModel = MessageModel(
        sender: FirebaseAuth.instance.currentUser!.uid,
        messageId: uuid.v1(),
        text: msg,
        seen: false,
        time: DateTime.now(),
      );
      firestore
          .collection('chatrooms')
          .doc(widget.chatModel!.chatRoomId)
          .collection('messages')
          .doc(messageModel.messageId)
          .set(messageModel.toMap());
      widget.chatModel!.lastMessage = msg;
      widget.chatModel!.lastMessageTime = DateTime.now();
      sendNotification([otherToken], msg, name).then((value) {
        print('notification sent ${value.body}');
      });
      firestore
          .collection('chatrooms')
          .doc(widget.chatModel!.chatRoomId)
          .set(widget.chatModel!.toMap());

      message.clear();
      debugPrint('message sent');
    }
  }
}
