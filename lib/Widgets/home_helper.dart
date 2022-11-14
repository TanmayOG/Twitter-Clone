import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twitter_clone/Screen/Profile/userProfile.dart';
import 'package:twitter_clone/Widgets/font.dart';
import 'package:twitter_clone/Widgets/full_image.dart';

import '../Constants/constants.dart';

import '../Screen/Login/login_ui.dart';
import '../Screen/Profile/otherProfile.dart';

drawer() {
  return Drawer(
    backgroundColor: Colors.black,
    child: ListView(children: <Widget>[
      StreamBuilder(
        stream: firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: const CircularProgressIndicator());
          }
          var data = (snapshot.data! as dynamic);
          return GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
                // on Tap open drawer
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfilePage(
                              id: FirebaseAuth.instance.currentUser!.uid,
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          (snapshot.data! as dynamic)['image'],
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      data['username'],
                      style: usernameF,
                    ),
                    subtitle: Text(
                      data['email'],
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  Row(children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.04,
                    ),
                    Text(data['following'].toString(), style: followF),
                    const Text("  following", style: followF),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.04,
                    ),
                    Text(data['follower'].toString(), style: followF),
                    const Text("  followers", style: followF),
                  ]),
                  const Divider(
                    color: Colors.grey,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline_rounded,
                      size: 22,
                    ),
                    title: const Text(
                      "Profile",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(
                            id: FirebaseAuth.instance.currentUser!.uid,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      size: 22,
                    ),
                    title: const Text(
                      "Logout",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      auth.signOut().whenComplete(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      });
                    },
                  ),
                ],
              ));
        },
      ),
    ]),
  );
}

appBar(BuildContext context) {
  return AppBar(
    actions: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CupertinoActivityIndicator();
            }
            var data = snapshot.data! as dynamic;
            return GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                  // on Tap open drawer
                },
                child: CachedNetworkImage(
                    imageUrl: data['image'],
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            data['image'],
                          ),
                        )));
          },
        ),
      ),
    ],
    title: Row(
      children: [
        const Hero(
          tag: 'logo',
          child: Icon(
            EvaIcons.twitter,
            size: 26,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.02,
        ),
        Text(
          "Twitter",
          style: GoogleFonts.lobster(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    ),
    backgroundColor: Colors.black,
  );
}
