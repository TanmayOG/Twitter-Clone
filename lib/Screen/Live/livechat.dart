import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/Widgets/app_provider.dart';
import 'package:twitter_clone/Widgets/font.dart';
import 'package:uuid/uuid.dart';

class LiveChat extends StatefulWidget {
  final String channelName;
  const LiveChat({Key? key, required this.channelName}) : super(key: key);

  @override
  State<LiveChat> createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChat> {
  TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final UserProvider user = Provider.of<UserProvider>(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: StreamBuilder<dynamic>(
            stream: FirebaseFirestore.instance
                .collection('live')
                .doc(widget.channelName)
                .collection('comments')
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      snapshot.data.docs[index].data()['username'],
                      style: TextStyle(
                        fontSize: 15,
                        color: snapshot.data.docs[index].data()['uid'] ==
                                FirebaseAuth.instance.currentUser!.uid
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      snapshot.data.docs[index].data()['message'],
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              );
            },
          )),
          TextFormField(
            // focusNode: _focusNode,
            controller: _textController,

            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  var id = Uuid().v1();
                  FirebaseFirestore.instance
                      .collection('live')
                      .doc(widget.channelName)
                      .collection('comments')
                      .doc(id)
                      .set({
                    'uid': FirebaseAuth.instance.currentUser!.uid,
                    'username': user.username ??
                        '${FirebaseAuth.instance.currentUser!.displayName}',
                    'message': _textController.text,
                    'createdAt': DateTime.now(),
                    'id': id,
                  }).then((value) {
                    _textController.clear();
                  });
                },
              ),
              hintText: 'Add a comment',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
