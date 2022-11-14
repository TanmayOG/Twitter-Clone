// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:twitter_clone/Constants/constants.dart';
import 'package:twitter_clone/Model/chat_model.dart';
import '../main.dart';

class AuthMethod {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  Future createUserCollection(BuildContext context, dynamic data) async {
    final User user = auth.currentUser!;
    final uid = user.uid;
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('users');
    await collectionReference.doc(uid).set(data);
  }

  addLikes(id, postId, tokenIdList) async {
    var snapshot = await firestore.collection('posts').doc(postId).get();

    var post = snapshot.data() as dynamic;
    DocumentSnapshot userDoc = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final userData = userDoc.data()! as dynamic;
    if (post['likes'].contains(FirebaseAuth.instance.currentUser!.uid)) {
      await firestore.collection('posts').doc(postId).update({
        'likes':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });
    } else {
      await firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      }).whenComplete(() {
        var name = userData['username'];
        if (userUid != post['creator']) {
          sendNotification([tokenIdList], '$name Like Your Tweet', 'Like');
        } else {
          print('same user');
        }
      });
    }
  }

  saveTwitt(BuildContext context, tweets, File? image) async {
    int data = DateTime.now().microsecondsSinceEpoch;
    Reference ref = FirebaseStorage.instance.ref().child('post_images/$data');
    UploadTask uploadTask = ref.putFile(image!.absolute);
    await Future.value(uploadTask);
    var imageUrl = await ref.getDownloadURL();
    DocumentSnapshot userDoc = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final userData = userDoc.data()! as dynamic;
    var comments = firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('comments')
        .snapshots();
    var postId = firestore.collection('posts').doc().id;
    await firestore.collection('posts').doc().set({
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'comments': 0,
      'username': userData['username'],
      'userImage': userData['image'],
      'tweets': tweets.toString(),
      'likes': [],
      'image': imageUrl.toString(),
      'tokenId': userData['tokenId'],
      'postId': postId.toString(),
      'retweetCount': [],
      'timestamp': DateTime.now().microsecond,
    }).whenComplete(() {
      toastMessage("Tweeted Successfully");
      Navigator.pop(context);
    });
  }

  deletePost(postId) async {
    await firestore.collection('posts').doc(postId).delete();
  }

  postComment(comment, postId, tokenIdList) async {
    var snapshot = await firestore.collection('posts').doc(postId).get();

    var post = snapshot.data() as dynamic;
    var userDoc = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var commentData =
        firestore.collection('posts').doc(postId).collection('comments');
    var userData = await commentData.get();

    if (comment.isNotEmpty) {
      await firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'comment': comment,
        'pin': false,
        'userImage': userDoc.data()!['image'],
        'tokenId': userDoc.data()!['tokenId'],
        'username': userDoc.data()!['username'],
        'id': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': DateTime.now(),
        'commentlikes': [],
      });
      await firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(1),
      });

      if (userUid != post['creator']) {
        sendNotification([tokenIdList],
            "${userDoc.data()!['username']} Comment On Your Tweet", "Comments");
      } else {
        print('same user');
      }
    } else {
      toastMessage("Comment can't be empty");
    }
    //
  }

  likeComment(postId, commentId) async {
    var snapshot = await firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();
    var comments = snapshot.docs.map((doc) => doc.data()).toList();

    if (comments.isNotEmpty) {
      for (var comment in comments) {
        if (comment['commentlikes']
            .contains(FirebaseAuth.instance.currentUser!.uid)) {
          await firestore
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .doc(commentId)
              .update({
            'commentlikes':
                FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
          });
        } else {
          await firestore
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .doc(commentId)
              .update({
            'commentlikes':
                FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
          });
        }
      }
    }
  }

  showComment(postId) async {
    var comments = await firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('pin')
        .get();
    return comments.docs;
  }

  getUserData(String uid) async {
    QuerySnapshot userVideo =
        await firestore.collection('users').where('id', isEqualTo: uid).get();

    return userVideo.docs;
  }

  isFollowing(myId, otherId) {
    return firestore
        .collection('users')
        .doc(myId)
        .collection('following')
        .doc(otherId)
        .snapshots()
        .map((snapshot) {
      return snapshot.exists;
    });
  }

  retweetFuction(postId, userName, tokenIdList, quote) async {
    var snapshot = await firestore.collection('posts').doc(postId).get();
    DocumentSnapshot userDoc = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final userData = userDoc.data()! as dynamic;
    var post = snapshot.data() as dynamic;
    var post1 = firestore.collection('posts').doc(postId);

    if (post['retweetCount'].contains(FirebaseAuth.instance.currentUser!.uid)) {
      await firestore.collection('posts').doc(postId).update({
        'retweetCount':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });
    } else {
      await firestore.collection('posts').doc(postId).update({
        'retweetCount':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      }).whenComplete(() {
        if (userUid != post['creator']) {
          sendNotification([tokenIdList],
              '${userData['username']} retweeted your tweet', 'Retweet');
        }
      });
    }
    var retweetdata = await post1
        .collection('retweets')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (retweetdata.docs.isEmpty) {
      await post1
          .collection('retweets')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'userId': FirebaseAuth.instance.currentUser!.uid});
      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('retweets')
          .doc(postId)
          .set({
        'postId': postId,
        'quote': quote.toString(),
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'creator': post['creator'],
        'userName': userName,
        'date': post['timestamp'],
      });
    } else {
      await post1
          .collection('retweets')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('retweets')
          .doc(postId)
          .delete();
    }
  }

  followUser(id, tokenIdList) async {
    DocumentSnapshot userDocs = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final userData = userDocs.data()! as dynamic;
    var name = userData['username'];
    var otherDoc = firestore.collection('users').doc(id);
    var myDoc = firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('following')
        .doc(id)
        .set({
      'id': id,
    }).then((value) async {
      await myDoc.update({
        'following': FieldValue.increment(1),
      });
    });

    await firestore
        .collection('users')
        .doc(id)
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'id': FirebaseAuth.instance.currentUser!.uid,
    }).then((value) async {
      await otherDoc.update({
        'follower': FieldValue.increment(1),
      });
      sendNotification([tokenIdList], '$name starting following you', 'follow');
    });
  }

  unFollowUser(id) async {
    DocumentSnapshot userDocs = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final userData = userDocs.data()! as dynamic;
    var otherDoc = firestore.collection('users').doc(id);
    var myDoc = firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('following')
        .doc(id)
        .delete()
        .then((value) async {
      await myDoc.update({
        'following': FieldValue.increment(-1),
      });
      await firestore
          .collection('users')
          .doc(id)
          .collection('followers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete()
          .then((value) async {
        await otherDoc.update({
          'follower': FieldValue.increment(-1),
        });
      });
    });
  }

  allPosts() async {
    var posts = await firestore.collection('posts').get();
    return posts.docs;
  }

  endLIveStream(String channelId) async {
    // QuerySnapshot snapshot = await firestore
    //     .collection('live')
    //     .doc(channelId)
    //     .collection('comments')
    //     .get();

    // for (int i = 0; i < snapshot.docs.length; i++) {
    //   await firestore
    //       .collection('live')
    //       .doc(channelId)
    //       .collection('comments')
    //       .doc((snapshot.docs[i].data() as dynamic)['commentId'])
    //       .delete();
    // }
    await firestore.collection('live').doc(channelId).delete();
  }

  Future<ChatModel?> getChatRoomMOdel(otherId) async {
    ChatModel? chatModel;
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(otherId).get();
    final userData = userDoc.data()! as dynamic;
    QuerySnapshot chatRoom = await firestore
        .collection('chatrooms')
        .where('participants.$userUid', isEqualTo: true)
        .where('participants.$otherId', isEqualTo: true)
        .get();
    if (chatRoom.docs.isNotEmpty) {
      var docData = chatRoom.docs[0].data() as dynamic;
      ChatModel existing = ChatModel.fromMap(docData as Map<String, dynamic>);
      chatModel = existing;
      log('chatroom found');
    } else {
      ChatModel chatModel = ChatModel(
          lastMessageTime: Timestamp.now(),
          chatRoomId: uuid.v1(),
          lastMessage: '',
          tokenId: userData['tokenId'],
          participants: {
            otherId: true,
            userUid: true,
          });
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatModel.chatRoomId)
          .set(chatModel.toMap());
      chatModel = chatModel;
      log('chatroom New Chat Room Created');
    }
    return chatModel;
  }

  updateViewCount(id, isINcrease) async {
    try {
      // if user leave the page, the view count will be decreased but cannot be negative

      final view = await firestore.collection('live').doc(id).get();
      final viewdoc = await firestore.collection('live').doc(id);

      // if view is zero then it will not be decreased
      if (view.data()!['viewer'] != 0) {
        if (isINcrease) {
          await viewdoc.update({
            'viewer': FieldValue.increment(1),
          });
        } else {
          await viewdoc.update({
            'viewer': FieldValue.increment(-1),
          });
        }
      }
    } catch (e) {}
  }
} //Loren
