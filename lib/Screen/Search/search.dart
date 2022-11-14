// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/Screen/Profile/otherProfile.dart';
import 'package:twitter_clone/Screen/Profile/userProfile.dart';
import 'package:twitter_clone/Widgets/app_provider.dart';

import '../../Constants/constants.dart';
import '../../Widgets/font.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? search = '';

  // search any letter  in the database

// var query =
  @override
  Widget build(BuildContext context) {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          toolbarHeight: 120,
          backgroundColor: Colors.black,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: TextFormField(
              style: const TextStyle(
                // color: Colors.black,
                fontSize: 15,
              ),
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Twitter',
                filled: true,
                contentPadding:
                    const EdgeInsets.only(top: 5.0, bottom: 4, left: 20),
                hintStyle: const TextStyle(
                  color: Colors.white54,
                ),
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          elevation: 0,
          leading: Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.grey[200],
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(
                      '${user.profilePhotoUrl}',
                    ),
                  )))),
      body: _searchController.text.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Center(
                  child: Text(
                    'What are you searching for?',
                    style: usernamePF,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'Search for twitter accounts or find similar result in this area',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('users')
                  .orderBy('username')
                  .startAt([
                    _searchController.text
                        .toLowerCase()
                        .toUpperCase() // containing any letter a -z in the database
                  ])
                  .endAt(['${_searchController.text}\uf8ff'])
                  .limit(10)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.hasData == null) {
                  return const Center(
                    child: Text('No Result Found'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
                var data = snapshot.data!.docs as dynamic;
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var followers = snapshot.data!.docs[index]['follower'];
                    var following = snapshot.data!.docs[index]['following'];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[200],
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(
                            snapshot.data!.docs[index]['image'],
                          ),
                        ),
                      ),
                      title: Text(snapshot.data!.docs[index]['username'],
                          style: usernameF),
                      subtitle: Row(
                        children: [
                          Text(
                            '$following Following',
                            style: followF,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text('$followers Followers', style: followF)
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => snapshot.data!.docs[index]
                                            ['id'] ==
                                        FirebaseAuth.instance.currentUser!.uid
                                    ? UserProfilePage()
                                    : ProfilePage(
                                        token: snapshot.data!.docs[index]
                                            ['tokenId'],
                                        id: snapshot.data!.docs[index]['id'],
                                      )));
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
