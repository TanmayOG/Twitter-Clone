// ignore_for_file: deprecated_member_use, avoid_init_to_null, unnecessary_null_comparison

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:twitter_clone/Constants/constants.dart';
import 'package:twitter_clone/Widgets/app_provider.dart';

class AddTwitt extends StatefulWidget {
  const AddTwitt({Key? key}) : super(key: key);

  @override
  State<AddTwitt> createState() => _AddTwittState();
}

class _AddTwittState extends State<AddTwitt> {

  String tweets = '';
  var loading;
  final picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  var video;
  List<String> arrayImg = [];
  final List _uploadedFileURL = [];
  final FirebaseStorage _storage = FirebaseStorage.instance;



  selectImage() async {
    try {
      final List<XFile>? imgs = await picker.pickMultiImage();
      if (imgs!.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(imgs);
          print('FILE PATH $_selectedFiles');
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  selectVideo() async {
    try {
      final XFile? pickedvideo =
          await picker.pickVideo(source: ImageSource.gallery);
      if (pickedvideo != null) {
        setState(() {
          video = pickedvideo;
          print('FILE PATH ${video.path}');
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  uploadFunction(List<XFile> _images) async {
    for (int i = 0; i < _images.length; i++) {
      var imageLIst = await uploadFile(_images[i]);

      arrayImg.add(imageLIst.toString());
    }
  }

  Future<String> uploadFile(XFile _image) async {
    int data = DateTime.now().microsecondsSinceEpoch;
    Reference ref = FirebaseStorage.instance.ref().child('post_images/$data');
    UploadTask uploadTask = ref.putFile(File(_image.path));
    await Future.value(uploadTask).then((value) async {
      await value.ref.getDownloadURL().then((value) async {
        _uploadedFileURL.add(value);
        print('URLSSSSSS  $_uploadedFileURL');
      });
    });
    return _uploadedFileURL.toString();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userData = Provider.of<UserProvider>(context, listen: false);
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        if (tweets.isEmpty) {
                          toastMessage('Please enter your tweets');
                        } else {
                          setState(() {
                            loading = true;
                          });
                          try {
                            if (_selectedFiles.isNotEmpty) {
                              await uploadFunction(_selectedFiles);
                            }

                            var comments = firestore
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('comments')
                                .snapshots();
                            var id = firestore.collection('posts').doc().id;
                            await firestore.collection('posts').doc(id).set({
                              'creator': FirebaseAuth.instance.currentUser!.uid,
                              'comments': 0,
                              'username': userData.username,
                              'userImage': userData.profilePhotoUrl,
                              'tweets': tweets.toString(),
                              'likes': [],
                              'tokenId': userData.tokenId,
                              'postid': id,
                              'image': _uploadedFileURL,
                              'retweetCount': [],
                              'timestamp': DateTime.now(),
                            }).whenComplete(() {
                              setState(() {
                                loading = false;
                              });
                              toastMessage("Tweeted Successfully");
                              Navigator.pop(context);
                            });
                          } catch (e) {
                            setState(() {
                              loading = false;
                            });
                            toastMessage("Something went wrong");
                          }
                        }
                      },
                      child: const Text('Tweet',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold))),
                )
              ],
            ),
            body: loading == true
                ? Center(
                    child: Lottie.asset(
                      "assets/2.json",
                      height: 250,
                      width: 250,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        flex: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      userData.profilePhotoUrl ?? ''),
                                ),
                                Wrap(
                                  children: [
                                    _selectedFiles.isNotEmpty
                                        ? Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                  color: Colors.transparent,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .22,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: GridView.builder(
                                                      itemCount:
                                                          _selectedFiles.length,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                              mainAxisSpacing:
                                                                  10,
                                                              crossAxisSpacing:
                                                                  10,
                                                              crossAxisCount:
                                                                  2),
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Image.file(
                                                          File(_selectedFiles[
                                                                  index]
                                                              .path),
                                                          fit: BoxFit.cover,
                                                        );
                                                      })),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    const SizedBox(height: 10),
                                    _selectedFiles.isEmpty
                                        ? TextFormField(
                                            onChanged: (value) {
                                              setState(() {
                                                tweets = value;
                                              });
                                            },
                                            maxLines: 200,
                                            decoration: const InputDecoration(
                                              hintText: 'What\'s happening?',
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              border: InputBorder.none,
                                            ),
                                          )
                                        : TextFormField(
                                            onChanged: (value) {
                                              setState(() {
                                                tweets = value;
                                              });
                                            },
                                            maxLines: 200,
                                            decoration: const InputDecoration(
                                              hintText: 'Enter your comments',
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                  ],
                                ),
                          
                          
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 25,
                          ),
                          video != null
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.image_rounded,
                                      size: 27,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      selectImage();
                                    },
                                  ),
                                ),
                          _selectedFiles.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedFiles.clear();
                                    });
                                  },
                                  icon: Icon(Icons.clear_rounded,
                                      color: Colors.grey[600]))
                              : Container(),
                          video != null
                              ? TextButton.icon(
                                  label: Text("Remove"),
                                  onPressed: () {
                                    setState(() {
                                      video = null;
                                    });
                                  },
                                  icon: Icon(Icons.clear_rounded,
                                      color: Colors.grey[600]))
                              : Container()
                        ],
                      ))
                    ],
                  )));
  }
}
