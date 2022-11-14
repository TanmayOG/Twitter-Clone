// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:twitter_clone/Constants/constants.dart';
import 'package:twitter_clone/Model/live_model.dart';
import 'package:twitter_clone/Screen/Live/liveScreen.dart';

class GoLive extends StatefulWidget {
  const GoLive({Key? key}) : super(key: key);

  @override
  State<GoLive> createState() => _GoLiveState();
}

class _GoLiveState extends State<GoLive> {
  File? image;
  bool? isLoad;
  TextEditingController title = TextEditingController();
  final picker = ImagePicker();
  String userUid = FirebaseAuth.instance.currentUser!.uid;

  getImage() async {
    final pickedfile = picker.getImage(source: ImageSource.gallery);
    pickedfile.then((value) {
      setState(() {
        image = File(value!.path);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: isLoad == true
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Lottie.asset(
                      "assets/load.json",
                      height: 250,
                      width: 250,
                    ),
                    const SizedBox(height: 10),
                    // uploading data
                    const Text(
                      'Livestream is uploading...',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ]))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      color: Colors.grey,
                      dashPattern: [10, 4],
                      strokeCap: StrokeCap.round,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.09),
                        ),
                        width: double.infinity,
                        child: image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        getImage();
                                      },
                                      child: const Icon(
                                        Icons.photo_size_select_large_rounded,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Select a thumbnail',
                                  )
                                ],
                              )
                            : Image.file(
                                File(image!.path),
                              ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: title,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            fillColor: Colors.grey.withOpacity(0.2),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            padding: const EdgeInsets.all(10),
                          ),
                          onPressed: () async {
                            setState(() {
                              isLoad = true;
                            });
                            int data = DateTime.now().microsecondsSinceEpoch;
                            Reference ref = FirebaseStorage.instance
                                .ref()
                                .child('thumbnail/$data');
                            UploadTask uploadTask =
                                ref.putFile(image!.absolute);
                            await Future.value(uploadTask);
                            var url = await ref.getDownloadURL();

                            DocumentSnapshot userDoc = await firestore
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .get();
                            final userData = userDoc.data()! as dynamic;
                            String channelId = '';
                            try {
                              if (title.text.isEmpty) {
                                throw Exception('Please fill all the fields');
                              } else {
                                if (!(await firestore
                                        .collection('livestream')
                                        .doc(userUid)
                                        .get())
                                    .exists) {
                                  String channelId =
                                      '$userUid${userData['email']}';
                                  final liveData = LiveModel(
                                    title: title.text,
                                    image: url,
                                    username: userData['username'],
                                    uid: FirebaseAuth.instance.currentUser!.uid,
                                    start: DateTime.now(),
                                    viewer: 0,
                                    channelId: channelId,
                                  );

                                  await firestore
                                      .collection('live')
                                      .doc(channelId)
                                      .set(liveData.toJson())
                                      .then((value) async {
                                    await firestore
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .update({
                                      'live': true,
                                    }).then((value) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LiveScreen(
                                                    channelName: channelId,
                                                    cast: true,
                                                  )));
                                      setState(() {
                                        isLoad = false;
                                        title.clear();
                                        image = null;
                                      });
                                    });
                                  });
                                }
                              }
                            } catch (e) {
                              setState(() {
                                isLoad = false;
                              });
                              toastMessage(e.toString());
                              debugPrint(e.toString());
                            }
                          },
                          child: const Text('Go Live'))
                    ],
                  ),
                ],
              ),
      )),
    );
  }
}
