import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:twitter_clone/Constants/constants.dart';

class BottomNavBar extends StatefulWidget {
  int? pageIndex;
  BottomNavBar({Key? key, this.pageIndex}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int page = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            setState(() {
              page = value;
            });
          },
          unselectedItemColor: Colors.grey,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          elevation: 0,
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.lightBlueAccent[300],
          currentIndex: widget.pageIndex == null ? page : widget.pageIndex!,
          items: [
            BottomNavigationBarItem(
              icon: page == 0
                  ? const Icon(Iconsax.home5, color: Colors.blue)
                  : const Icon(Iconsax.home4, color: Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: page == 1
                  ? const Icon(EvaIcons.search, color: Colors.blue)
                  : const Icon(EvaIcons.searchOutline, color: Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: page == 2
                  ? const Icon(Iconsax.activity5, color: Colors.blue)
                  : const Icon(Iconsax.activity, color: Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: page == 3
                  ? const Icon(Iconsax.profile_circle5, color: Colors.blue)
                  : const Icon(Iconsax.profile_circle, color: Colors.grey),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: page == 4
                  ? const Icon(Iconsax.message_2, color: Colors.blue)
                  : const Icon(Iconsax.message_24, color: Colors.grey),
              label: '',
            ),
          ]),
      body: pages[page],
    );
  }
}
