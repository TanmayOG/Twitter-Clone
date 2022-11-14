import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/Widgets/app_provider.dart';
import 'package:twitter_clone/Widgets/bottom_nav.dart';
import 'package:twitter_clone/Widgets/loginbutton.dart';
import '../../Constants/constants.dart';
import '../Home/home.dart';
import '../Reset/reset_password.dart';
import '../SignUp/signup_ui.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  bool? _isLoading;

  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(),
        child: SafeArea(
          child: _isLoading == true
              ? Center(
                  child: Lottie.asset(
                    "assets/2.json",
                    height: 250,
                    width: 250,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Column(
                        children: const [
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Welcome Back !',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Sign in to continue',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                          SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          controller: email,
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
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          controller: password,
                          decoration: InputDecoration(
                              fillColor: Colors.blueGrey[1600],
                              filled: true,
                              hintText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const ResetPassword();
                              }));
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      LoginButton(
                          title: 'Login',
                          onPressed: () async {
                            try {
                              if (email.text.isNotEmpty ||
                                  password.text.isNotEmpty) {
                                try {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  UserCredential userCredential =
                                      await FirebaseAuth
                                          .instance
                                          .signInWithEmailAndPassword(
                                              email: email.text,
                                              password: password.text)
                                          .then((value) {
                                    if (value.user != null) {
                                      Provider.of<UserProvider>(context,
                                              listen: false)
                                          .getUserData();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BottomNavBar()));
                                      email.clear();
                                      password.clear();
                                    } else {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      toastMessage(
                                        "Please enter valid credentials",
                                      );
                                    }
                                    return value;
                                  });
                                } on FirebaseAuthException catch (e) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (e.code == 'user-not-found') {
                                    toastMessage(
                                        'No user found for that email.');
                                  } else if (e.code == 'wrong-password') {
                                    toastMessage(
                                        'Wrong password provided for that user.');
                                  }
                                }
                              } else {
                                setState(() {
                                  _isLoading = false;
                                });
                                toastMessage(
                                    'Please Enter Valid Email and Password');
                              }
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                              toastMessage(e.toString());
                            }
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account?',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return SignUpScreen();
                              }));
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
