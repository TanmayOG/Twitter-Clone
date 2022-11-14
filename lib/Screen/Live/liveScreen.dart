// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:twitter_clone/Widgets/bottom_nav.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/Constants/constants.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:twitter_clone/Database/auth_method.dart';
import 'package:twitter_clone/Screen/Home/home.dart';
import 'package:twitter_clone/Widgets/app_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../Widgets/bottom_nav.dart';

class LiveScreen extends StatefulWidget {
  final bool? cast;
  final String? channelName;

  const LiveScreen({
    Key? key,
    this.cast,
    this.channelName,
  }) : super(key: key);

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> with WidgetsBindingObserver {
  RtcEngine? _engine;
  List<int> remoteUid = [];
  final users = FirebaseAuth.instance.currentUser;
  var token;
  TextEditingController _textController = TextEditingController();

  /// Check if users is in this page or not
  /// if not then return to home page
  /// if yes then continue with help of appLife state
  /// if appLife is true then return to home page
  /// if appLife is false then continue with help of appLife state

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _textController.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeAgora();
    WidgetsBinding.instance.addObserver(this);
    print(widget.cast);
    log('Channel ID  ${widget.channelName}:  "${FirebaseAuth.instance.currentUser!.uid}${FirebaseAuth.instance.currentUser!.email}")');
  }

  AppLifecycleState? _notification;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
    print('Current state = $_notification');
  }

  getToken() async {
    final response = await http.get(Uri.parse(
        '$baseUrl/rtc/${widget.channelName}/publisher/userAccount/$userId/'));
    if (response.statusCode == 200) {
      setState(() {
        token = response.body;
        token = jsonDecode(response.body)['rtcToken'];
      });
      log('Token: $token');
    } else {
      print(response.statusCode);
    }
  }

  initializeAgora() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    addListeners();

    await _engine?.enableVideo();

    await _engine?.startPreview();
    await _engine?.setChannelProfile(ChannelProfile.LiveBroadcasting);
    log('caster  ${widget.cast}');

    if (widget.cast == true) {
      _engine!.setClientRole(ClientRole.Broadcaster);
      log('Casting');
    } else {
      _engine!.setClientRole(ClientRole.Audience);
      log('Listening');
    }
    joinChannel();
  }

  joinChannel() async {
    await getToken();
    if (token != null) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await [Permission.camera, Permission.microphone].request();
      }
      await _engine
          ?.joinChannelWithUserAccount(token, widget.channelName!,
              FirebaseAuth.instance.currentUser!.uid)
          .then((value) {
        log('Joined channel');
      });
    }
  }

  addListeners() {
    _engine!.setEventHandler(
        RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
      log('joinChannelSuccess $channel $uid $elapsed');
    }, userJoined: (uid, elapsed) {
      log('userJoined $uid $elapsed');
      setState(() {
        remoteUid.add(uid);
      });
    }, userInfoUpdated: (uid, reason) {
      log('userInfoUpdated $uid ${reason.uid}');
    }, userOffline: (uid, reason) {
      print('userOffline');
      log('userOffline $uid ${reason}');
      if (reason == UserOfflineReason.Quit) {
        endStream = true;
        setState(() {
          remoteUid.remove(uid);
        });
        _engine!.destroy();
      }
      // setState(() {
      //   remoteUid.removeWhere((uid) => uid == uid);
      // });
    }, streamMessage: (uid, streamId, msg) {
      log('streamMessage $uid $streamId $msg');
    }, leaveChannel: (stats) {
      print('leaveChannel $stats');
      setState(() {
        remoteUid.clear();
      });
    }, connectionStateChanged: (state, reason) {
      print('connectionStateChanged $state $reason');
      log('connectionStateChanged $state $reason');
    }, tokenPrivilegeWillExpire: (token) async {
      await getToken();
      _engine!.renewToken(token);
    }));
  }

  var switchCamera = true;
  var isMuted = false;

  onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine?.muteLocalAudioStream(isMuted);
  }

  _switchCamera() {
    _engine?.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final UserProvider user = Provider.of<UserProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        // Navigator.pop(context);
        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          body: ListView(
            children: [
              endStream == true
                  ? userSideLeave()
                  : _renderVideo(context, user.profilePhotoUrl, user.username),
              // _renderVideo(false),
            ],
          ),
        ),
      ),
    );
  }

  userSideLeave() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
          ),
          Text(
            'Host has left the channel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              await _engine?.leaveChannel();
            },
            child: Text('Leave'),
          ),
        ],
      ),
    );
  }

  var endStream;
  _leaveChannel() async {
    // await _engine!.leaveChannel();
    if ("${FirebaseAuth.instance.currentUser!.uid}${FirebaseAuth.instance.currentUser!.email}" ==
        widget.channelName) {
      await AuthMethod().endLIveStream(widget.channelName!);
      await _engine?.destroy().then((value) {
        log('Destroyed');
        // if host end the stream then delete the channel

        log('End stream $endStream');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BottomNavBar()));
      });
      log('Destroyed');
      // await _engine?.;
    } else {
      log('Not destroyed');
      await AuthMethod().updateViewCount(widget.channelName as String, false);

      // navigate popup
      Navigator.of(context).pop();

      await _engine?.leaveChannel();
    }
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  bool isScreenSharing = false;
  _renderVideo(context, profilePhotoUrl, username) {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child:
                  "${FirebaseAuth.instance.currentUser!.uid}${FirebaseAuth.instance.currentUser!.email}" ==
                          widget.channelName
                      ? isScreenSharing
                          ? kIsWeb
                              ? const RtcLocalView.SurfaceView.screenShare()
                              : const RtcLocalView.TextureView.screenShare()
                          : const RtcLocalView.SurfaceView(
                              zOrderMediaOverlay: true,
                              zOrderOnTop: true,
                            )
                      : isScreenSharing
                          ? kIsWeb
                              ? const RtcLocalView.SurfaceView.screenShare()
                              : const RtcLocalView.TextureView.screenShare()
                          : remoteUid.isNotEmpty
                              ? kIsWeb
                                  ? RtcRemoteView.SurfaceView(
                                      uid: remoteUid[0],
                                      channelId: widget.channelName!,
                                    )
                                  : RtcRemoteView.TextureView(
                                      uid: remoteUid[0],
                                      channelId: widget.channelName!,
                                    )
                              : Container(),
            ),
            Positioned(
                bottom: MediaQuery.of(context).size.height * 0.17,
                left: MediaQuery.of(context).size.width / 2 - 180,
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width,
                    child: StreamBuilder<dynamic>(
                      stream: FirebaseFirestore.instance
                          .collection('live')
                          .doc(widget.channelName)
                          .collection('comments')
                          .orderBy("createdAt", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: const CupertinoActivityIndicator(),
                          );
                        }
                        return ListView.builder(
                          reverse: true,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                snapshot.data.docs[index].data()['username'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: snapshot.data.docs[index]
                                              .data()['uid'] ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                snapshot.data.docs[index].data()['message'],
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ))),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.05,
              // left: MediaQuery.of(context).size.width * 0.05,
              child: Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width,
                child: ListTile(
                  title: TextFormField(
                    // focusNode: _focusNode,
                    controller: _textController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Iconsax.send_sqaure_2,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          var id = const Uuid().v1();
                          FirebaseFirestore.instance
                              .collection('live')
                              .doc(widget.channelName)
                              .collection('comments')
                              .doc(id)
                              .set({
                            'uid': FirebaseAuth.instance.currentUser!.uid,
                            'userImage': profilePhotoUrl,
                            'username': username ??
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
                ),
              ),
            ),
            if (widget.channelName ==
                "${FirebaseAuth.instance.currentUser!.uid}${FirebaseAuth.instance.currentUser!.email}")
              Positioned(
                // top: 0,
                right: 0,
                bottom: MediaQuery.of(context).size.height * 0.3,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                            onTap: () {
                              _switchCamera();
                            },
                            child: const Icon(Icons.cameraswitch_sharp,
                                size: 30, color: Colors.white)),
                        GestureDetector(
                            onTap: () {
                              onToggleMute();
                            },
                            child: Icon(
                                isMuted
                                    ? Iconsax.microphone5
                                    : Iconsax.microphone_slash_15,
                                size: 30,
                                color: Colors.white)),
                        GestureDetector(
                          onTap: () async {
                            // show dialog
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: const Text("Leave Channel"),
                                  content: const Text(
                                      "Are you sure you want to end this live?"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text("Yes"),
                                      onPressed: () async {
                                        log('${widget.channelName} : Channel id');
                                        _leaveChannel();
                                        Navigator.of(context).pop();
                                        // await AuthMethod()
                                        //     .endLIveStream(widget.channelName!);
                                        // Navigator.pushReplacement(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: ((context) =>
                                        //             BottomNavBar(
                                        //               pageIndex: 2,
                                        //             ))));
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("No"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        log('remote uid : ${remoteUid.length}');
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Icon(Iconsax.close_circle5,
                              size: 30, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  // _renderVideo(isScreenSharing) {
  //   return AspectRatio(
  //     aspectRatio: 16 / 9,
  //     child:
  //         "${FirebaseAuth.instance.currentUser!.uid}${FirebaseAuth.instance.currentUser!.email}" ==
  //                 widget.channelName!
  //             ? RtcLocalView.SurfaceView(
  //                 zOrderMediaOverlay: true,
  //                 zOrderOnTop: true,
  //               )
  //             : remoteUid.isNotEmpty
  //                 ? kIsWeb
  //                     ? RtcRemoteView.SurfaceView(
  //                         uid: remoteUid[0],
  //                         channelId: widget.channelName!,
  //                       )
  //                     : RtcRemoteView.TextureView(
  //                         uid: remoteUid[0],
  //                         channelId: widget.channelName!,
  //                       )
  //                 : Container(),
  //   );
  // }

}
