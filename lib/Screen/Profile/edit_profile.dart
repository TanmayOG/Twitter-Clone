// ignore_for_file: unnecessary_null_comparison, prefer_if_null_operators

import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/Constants/constants.dart';
import 'package:twitter_clone/Database/storage.dart';
import 'package:twitter_clone/Widgets/app_provider.dart';

import '../../Widgets/bottom_nav.dart';

class EditProfile extends StatefulWidget {
  final image;
  final bio;
  final displayName;
  final cover;
  const EditProfile(
      {Key? key, this.image, this.bio, this.displayName, this.cover})
      : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayName = TextEditingController();
  TextEditingController bio = TextEditingController();
  TextEditingController photourl = TextEditingController();
  User? user;

  var _pickedImage;
  var profilepickedImage;
  final picker = ImagePicker();
  var load;
  @override
  Widget build(BuildContext context) {
    UserProvider userData = Provider.of<UserProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black,
          body: load == false
              ? Center(
                  child: Lottie.asset(
                    "assets/2.json",
                    height: 250,
                    width: 250,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.32,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                getImage();
                                print(userData.email);
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * .22,
                                  width: MediaQuery.of(context).size.width,
                                  child: _pickedImage != null
                                      ? Image.file(
                                          _pickedImage!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          widget.cover == ""
                                              ? "https://firebasestorage.googleapis.com/v0/b/twitter-ba95d.appspot.com/o/no-image-6663.png?alt=media&token=528e706a-f013-4d4f-be37-192b3476c4cb"
                                              : widget.cover,
                                          width: 100,
                                          color: Colors.white,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Positioned(
                              left: MediaQuery.of(context).size.width * .35,
                              top: MediaQuery.of(context).size.height * .14,
                              child: GestureDetector(
                                onTap: () {
                                  profileImage();
                                },
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: profilepickedImage == null
                                      ? NetworkImage(widget.image)
                                      : FileImage(profilepickedImage)
                                          as ImageProvider,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextFormField(
                          // controller: displayName,
                          initialValue: widget.displayName,
                          onChanged: ((value) {
                            displayName.text = value;
                          }),
                          decoration: const InputDecoration(
                            filled: true,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Name',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextFormField(
                          onChanged: ((value) {
                            bio.text = value;
                          }),
                          maxLength: 100,
                          maxLines: 5,
                          initialValue: widget.bio,
                          decoration: const InputDecoration(
                            filled: true,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'bio',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromARGB(255, 41, 70, 83),
                          ),
                          onPressed: () async {
                            setState(() {
                              load = false;
                            });
                            var url;
                            var cover;
                            if (displayName.text.isEmpty) {
                              displayName.text = widget.displayName;
                            }

                            if (profilepickedImage == null) {
                              url = widget.image;
                            } else {
                              url = await StorageService.uploadTweetPicture(
                                  profilepickedImage);
                            }
                            if (_pickedImage == null) {
                              cover = widget.cover;
                            } else {
                              cover = await StorageService.uploadTweetPicture(
                                  _pickedImage);
                            }
                            if (bio.text.isEmpty) {
                              bio.text = widget.bio;
                            }

                            try {
                              await firestore
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                'cover': cover.toString(),
                                'bio': bio.text,
                                'username': displayName.text == null
                                    ? widget.displayName
                                    : displayName.text,
                                'image': url.toString() == null
                                    ? userData.profilePhotoUrl
                                    : url.toString(),
                              }).whenComplete(() {
                                setState(() {
                                  load = true;
                                });
                                Navigator.pop(context);
                                toastMessage('Profile Updated Successfully');
                                setState(() {});
                              });
                            } catch (e) {
                              setState(() {
                                load = true;
                              });
                              toastMessage(e.toString());
                              debugPrint(e.toString());
                            }
                          },
                          child: const Text('Update')),
                    ],
                  ),
                )),
    );
  }

  getImage() async {
    final pickedfile = picker.getImage(source: ImageSource.gallery);
    pickedfile.then((value) {
      setState(() {
        _pickedImage = File(value!.path);
      });
    });
  }

  profileImage() async {
    final pickedfile = picker.getImage(source: ImageSource.gallery);
    pickedfile.then((value) {
      setState(() {
        profilepickedImage = File(value!.path);
      });
    });
  }
}
