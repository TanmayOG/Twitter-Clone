// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:twitter_clone/Constants/constants.dart';
// import 'package:twitter_clone/Widgets/full_image.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:twitter_clone/Widgets/sheetHelper.dart';

// class DetailPage extends StatefulWidget {
//   final id;
//   final name;
//   final image;
//   final tweet;
//   final tokenId;
//   final tweetImage;
//   final likes;
//   final retweetCount;
//   final date;
//   final postid;
//   final retweet;

//   const DetailPage(
//       {Key? key,
//       this.id,
//       this.name,
//       this.tokenId,
//       this.image,
//       this.retweet,
//       this.tweet,
//       this.tweetImage,
//       this.likes,
//       this.retweetCount,
//       this.date,
//       this.postid})
//       : super(key: key);

//   @override
//   _DetailPageState createState() => _DetailPageState();
// }

// class _DetailPageState extends State<DetailPage> {
//   bool isReadmore = false;
//   final _focusNode = FocusNode();
//   var _comment;
//   TextEditingController _controller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Colors.black,
//           title: const Text(
//             'Tweet',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: SizedBox(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             child: Column(
//               children: [
//                 Expanded(
//                     flex: 13,
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height,
//                       width: MediaQuery.of(context).size.width,
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ListTile(
//                               leading: CircleAvatar(
//                                 radius: 30,
//                                 backgroundImage: NetworkImage(widget.image),
//                               ),
//                               title: Text(
//                                 widget.name.toString().toTitleCase(),
//                                 style: GoogleFonts.ibmPlexSans(
//                                     fontSize: 18, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: buildText(widget.tweet),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Align(
//                                 alignment: Alignment.bottomRight,
//                                 child: GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         // toggle the bool variable true or false
//                                         isReadmore = !isReadmore;
//                                       });
//                                     },
//                                     child: widget.tweet.length > 400
//                                         ? Text(
//                                             (isReadmore
//                                                 ? 'Show less'
//                                                 : 'Show more'),
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.blue[400],
//                                               fontWeight: FontWeight.bold,
//                                             ))
//                                         : Container()),
//                               ),
//                             ),
//                             widget.tweetImage == ""
//                                 ? Container()
//                                 : GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   DetailScreen(
//                                                     id: widget.tweetImage,
//                                                   )));
//                                     },
//                                     child: Padding(
//                                       padding: EdgeInsets.all(
//                                           MediaQuery.of(context).size.width *
//                                               0.02),
//                                       child: Container(
//                                         height:
//                                             MediaQuery.of(context).size.height *
//                                                 0.4,
//                                         width:
//                                             MediaQuery.of(context).size.width,
//                                         decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             image: DecorationImage(
//                                                 image: NetworkImage(
//                                                     widget.tweetImage),
//                                                 fit: BoxFit.cover)),
//                                       ),
//                                     ),
//                                   ),
//                             ListTile(
//                               leading: Text(
//                                 DateFormat('KK:MM a   dd MMM yy')
//                                     .format(widget.date.toDate()),
//                                 style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey),
//                               ),
//                             ),
//                             const Divider(
//                               thickness: 1,
//                               color: Colors.grey,
//                             ),
//                             StreamBuilder<QuerySnapshot>(
//                                 stream: FirebaseFirestore.instance
//                                     .collection('posts')
//                                     .where('creator', isEqualTo: widget.id)
//                                     .snapshots(includeMetadataChanges: true),
//                                 builder: (BuildContext context,
//                                     AsyncSnapshot<QuerySnapshot> snapshot) {
//                                   if (snapshot.hasError) {
//                                     return const Text("Something went wrong");
//                                   }
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return const Text("Loading");
//                                   }
//                                   var tweetdata = snapshot.data!.docs;
//                                   var isLike =
//                                       tweetdata[0]['likes'].contains(widget.id);

//                                   return Row(children: [
//                                     SizedBox(
//                                       width: MediaQuery.of(context).size.width *
//                                           0.04,
//                                     ),
//                                     Text(
//                                       tweetdata[0]['retweetCount']
//                                           .length
//                                           .toString(),
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 17),
//                                     ),
//                                     const Text(
//                                       "  Retweets",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.grey,
//                                           fontSize: 17),
//                                     ),
//                                     SizedBox(
//                                       width: MediaQuery.of(context).size.width *
//                                           0.04,
//                                     ),
//                                     Text(
//                                         tweetdata[0]['likes'].length.toString(),
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 17)),
//                                     const Text(
//                                       "  Likes",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.grey,
//                                           fontSize: 17),
//                                     ),
//                                   ]);
//                                 }),
//                             const Divider(
//                               thickness: 1,
//                               color: Colors.grey,
//                             ),
//                             StreamBuilder(
//                                 stream: FirebaseFirestore.instance
//                                     .collection('posts')
//                                     .where('creator', isEqualTo: widget.id)
//                                     .snapshots(includeMetadataChanges: true),
//                                 builder: (BuildContext context, snapshot) {
//                                   if (snapshot.hasError) {
//                                     return const Text("Something went wrong");
//                                   }
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return const Text("Loading");
//                                   }
//                                   QuerySnapshot tweetdata =
//                                       snapshot.data as QuerySnapshot;
//                                   var isRetweeted = tweetdata.docs[0]
//                                           ['retweetCount']
//                                       .contains(widget.id);
//                                   var isLike = tweetdata.docs[0]['likes']
//                                       .contains(widget.id);

//                                   return Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceAround,
//                                       children: [
//                                         IconButton(
//                                           icon: const Icon(
//                                               Icons.insert_comment_outlined,
//                                               color: Colors.grey),
//                                           onPressed: () {
//                                             _focusNode.requestFocus();
//                                           },
//                                         ),
//                                         RotatedBox(
//                                           quarterTurns: 3,
//                                           child: IconButton(
//                                             icon: Icon(
//                                               CupertinoIcons.repeat,
//                                               size: 20,
//                                               color: isRetweeted
//                                                   ? Color.fromARGB(
//                                                       255, 29, 212, 38)
//                                                   : Colors.grey[700],
//                                             ),
//                                             onPressed: () {
//                                               // print(checker.checker);
//                                               retweetSheet(
//                                                   widget.postid,
//                                                   widget.name,
//                                                   [widget.tokenId]);
//                                             },
//                                           ),
//                                         ),
//                                         IconButton(
//                                           icon: isLike
//                                               ? const Icon(
//                                                   CupertinoIcons
//                                                       .suit_heart_fill,
//                                                   size: 20,
//                                                   color: Colors.red,
//                                                 )
//                                               : Icon(
//                                                   CupertinoIcons.suit_heart,
//                                                   size: 20,
//                                                   color: Colors.grey[500],
//                                                 ),
//                                           onPressed: () {
//                                             authClass.addLikes(
//                                                 widget.id,
//                                                 tweetdata.docs[0].id,
//                                                 tweetdata.docs[0]['tokenId']);
//                                           },
//                                         )
//                                       ]);
//                                 }),
//                             const Divider(
//                               thickness: 1,
//                               color: Colors.grey,
//                             ),
//                             FutureBuilder(
//                                 future: authClass.showComment(widget.postid),
//                                 builder: (context, AsyncSnapshot snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return const Center(
//                                         child: CircularProgressIndicator());
//                                   } else if (snapshot.hasError) {
//                                     return const Center(
//                                         child: Text("Something went wrong"));
//                                   } else {
//                                     var data = snapshot.data;

//                                     return ListView.builder(
//                                         // physics: const ClampingScrollPhysics(),
//                                         shrinkWrap: true,
//                                         itemCount: data.length,
//                                         itemBuilder: (context, index) =>
//                                             ListTile(
//                                               leading: CircleAvatar(
//                                                 backgroundColor: Colors.black,
//                                                 backgroundImage: NetworkImage(
//                                                     data[index]['userImage']
//                                                         as String),
//                                               ),
//                                               title: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Text(
//                                                     data[index]['username']
//                                                         as String,
//                                                     style: const TextStyle(),
//                                                   ),
//                                                   const SizedBox(width: 10),
//                                                   Align(
//                                                     alignment:
//                                                         Alignment.topRight,
//                                                     child: Text(
//                                                       timeago.format(data[index]
//                                                               ['timestamp']
//                                                           .toDate()),
//                                                       style: const TextStyle(
//                                                           fontSize: 13,
//                                                           color: Colors.grey),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               subtitle: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Text(data[index]['comment']
//                                                       as String),
//                                                   const SizedBox(width: 10),
//                                                   StreamBuilder(
//                                                       stream: firestore
//                                                           .collection('posts')
//                                                           .doc(widget.postid)
//                                                           .collection(
//                                                               'comments')
//                                                           .doc(data[index].id)
//                                                           .snapshots(),
//                                                       builder:
//                                                           (context, snapshot) {
//                                                         if (snapshot.hasError) {
//                                                           return const Center(
//                                                             child: Icon(
//                                                                 Icons.error),
//                                                           );
//                                                         }
//                                                         if (snapshot
//                                                                 .connectionState ==
//                                                             ConnectionState
//                                                                 .waiting) {
//                                                           return const Center(
//                                                             child:
//                                                                 CircularProgressIndicator(),
//                                                           );
//                                                         }
//                                                         var commentData = snapshot
//                                                                 .data
//                                                             as DocumentSnapshot;
//                                                         return Align(
//                                                             alignment: Alignment
//                                                                 .topRight,
//                                                             child: Column(
//                                                               children: [
//                                                                 IconButton(
//                                                                     icon: Icon(
//                                                                       Icons
//                                                                           .favorite_rounded,
//                                                                       color: commentData['commentlikes'].contains(FirebaseAuth
//                                                                               .instance
//                                                                               .currentUser!
//                                                                               .uid)
//                                                                           ? Colors
//                                                                               .red
//                                                                           : Colors
//                                                                               .grey,
//                                                                       size: 15,
//                                                                     ),
//                                                                     onPressed:
//                                                                         () {
//                                                                       authClass
//                                                                           .likeComment(
//                                                                         widget
//                                                                             .postid,
//                                                                         data[index]
//                                                                             .id,
//                                                                       );
//                                                                     }),
//                                                                 Text(
//                                                                   commentData[
//                                                                           'commentlikes']
//                                                                       .length
//                                                                       .toString(),
//                                                                   style: const TextStyle(
//                                                                       fontSize:
//                                                                           13,
//                                                                       color: Colors
//                                                                           .grey),
//                                                                 ),
//                                                               ],
//                                                             ));
//                                                       }),
//                                                 ],
//                                               ),
//                                             ));
//                                   }
//                                 })
//                           ],
//                         ),
//                       ),
//                     )),
//                 Expanded(
//                   flex: 1,
//                   child: ListTile(
//                     title: TextFormField(
//                       focusNode: _focusNode,
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         suffixIcon: IconButton(
//                           icon: const Icon(Icons.send),
//                           onPressed: () {
//                             authClass.postComment(_controller.text,
//                                 widget.postid, [widget.tokenId]);
//                             _focusNode.unfocus();
//                             _controller.clear();
//                           },
//                         ),
//                         hintText: 'Add a comment',
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }

//   Widget buildText(String text) {
//     // if read more is false then show only 3 lines from text
//     // else show full text
//     final lines = isReadmore ? null : 3;
//     return Text(
//       text,
//       style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w600),
//       maxLines: text.length > 5 ? lines : null,
//       // overflow properties is used to show 3 dot in text widget
//       // so that user can understand there are few more line to read.
//       overflow: isReadmore ? TextOverflow.visible : TextOverflow.ellipsis,
//     );
//   }
// }
