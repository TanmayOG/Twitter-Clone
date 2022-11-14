// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/Widgets/app_provider.dart';
import 'package:twitter_clone/Widgets/font.dart';
import 'package:uuid/uuid.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:twitter_clone/Constants/constants.dart';
import 'dart:developer' as developer;
import 'package:twitter_clone/Screen/Login/login_ui.dart';
import 'package:twitter_clone/Widgets/bottom_nav.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

var uuid = const Uuid();
void main() async {
// Firebase initialisation
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
    developer.log('Connection status: $_connectionStatus');
  }

  @override
  void initState() {
    super.initState();
    configOneSignal();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  configOneSignal() {
    OneSignal.shared.setAppId(ONESIGNAL_APP_ID);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(

          // themeMode:
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.black,
              // ignore: unnecessary_const
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            scaffoldBackgroundColor: Colors.black,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
          home: _connectionStatus == ConnectivityResult.none
              ? Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Center(
                        child: Icon(
                          Iconsax.wifi_square,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                      const Center(
                        child: const Text(
                          "Oops!",
                          style: usernamePF,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            "No Internet Connection Found Check Your Internet Connection",
                            style: tweetF,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TextButton(
                        child: Text("Try Again"),
                        onPressed: () {},
                      )
                    ],
                  ),
                )
              : const SplashScreen()),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // check user login status
    // if user is login then navigate to home screen else navigate to login screen
    if (auth.currentUser != null) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) =>  BottomNavBar()),
            (route) => false);
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: 'logo',
          child: Icon(
            EvaIcons.twitter,
            color: Colors.blue,
            size: MediaQuery.of(context).size.width * 0.25,
          ),
        ),
      ),
    );
  }
}
