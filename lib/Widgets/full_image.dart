import 'package:flutter/material.dart';
import 'package:twitter_clone/Widgets/imageswipe.dart';

class DetailScreen extends StatelessWidget {
  final id;
  DetailScreen({this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: ImageSwipe(
            height: MediaQuery.of(context).size.height * 0.6,
            imageList: id,
          )),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
