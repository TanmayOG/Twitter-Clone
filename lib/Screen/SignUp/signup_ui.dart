import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:twitter_clone/Constants/constants.dart';
import 'package:twitter_clone/Widgets/bottom_nav.dart';
import 'package:twitter_clone/Widgets/loginbutton.dart';
import '../Login/login_ui.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool? _isLoading;
  int index = 0;
  final PageController _pageController = PageController();
  String email = '';
  String password = '';
  String name = '';
  File? image;
  final picker = ImagePicker();
  bool obsecure = true;
  String? url;
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

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
    return Scaffold(
      body: SafeArea(
        child: _isLoading == true
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
                      'Setting up your account',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ]))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Create an account",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          getImage();
                        });
                      },
                      child: Center(
                        child: image == null
                            ? const Icon(Icons.photo_camera, size: 50)
                            : CircleAvatar(
                                radius: 60,
                                backgroundImage: FileImage(image!),
                              ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: emailcontroller,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        decoration: InputDecoration(
                            fillColor: Colors.blueGrey[1600],
                            filled: true,
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: namecontroller,
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        decoration: InputDecoration(
                            fillColor: Colors.blueGrey[1600],
                            filled: true,
                            hintText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: passwordcontroller,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        obscureText: obsecure == true ? true : false,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obsecure = !obsecure;
                                });
                              },
                              icon: obsecure == true
                                  ? const Icon(Icons.visibility,
                                      color: Colors.blueGrey)
                                  : const Icon(Icons.visibility_off,
                                      color: Colors.grey),
                            ),
                            fillColor: Colors.blueGrey[1600],
                            filled: true,
                            hintText: 'Set Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return LoginScreen();
                            }));
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    LoginButton(
                      title: 'Sign Up',
                      onPressed: () async {
                        if (emailcontroller.text.isEmpty ||
                            passwordcontroller.text.isEmpty) {
                          toastMessage('Please fill all the fields');
                        } else if (image == null) {
                          toastMessage('Please select an image');
                        } else if (namecontroller.text.isEmpty) {
                          toastMessage('Please enter your name');
                        } else if (emailcontroller.text
                                .contains('@gmail.com') ==
                            false) {
                          toastMessage('Please enter a valid email');
                        } else {
                          try {
                            int data = DateTime.now().microsecondsSinceEpoch;

                            setState(() {
                              _isLoading = true;
                            });
                            Reference ref = FirebaseStorage.instance
                                .ref()
                                .child('post_images/$data');
                            UploadTask uploadTask =
                                ref.putFile(image!.absolute);
                            await Future.value(uploadTask);
                            var url = await ref.getDownloadURL();
                            var status =
                                await OneSignal.shared.getDeviceState();
                            String? tokenId = status!.userId;
                            final user = (await auth
                                    .createUserWithEmailAndPassword(
                                        email: email, password: password)
                                    .whenComplete(() {
                              authClass.createUserCollection(context, {
                                'email': emailcontroller.text,
                                'password': passwordcontroller.text,
                                'username': namecontroller.text,
                                'tokenId': tokenId,
                                'bio': "",
                                "cover": "",
                                'live': false,
                                'image': url.toString(),
                                'follower': 0,
                                'following': 0,
                                'date': DateTime.now(),
                                'id': FirebaseAuth.instance.currentUser!.uid,
                              });
                            }))
                                .user;
                            if (user != null) {
                              setState(() {
                                _isLoading = false;
                              });
                              toastMessage('Account Created Successfully');
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                           BottomNavBar()),
                                  (route) => false);
                            }
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });
                            toastMessage(e.toString());
                          }
                        }
                      },
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
