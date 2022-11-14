// ignore_for_file: avoid_types_as_parameter_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ImageSwipe extends StatefulWidget {
  final List? imageList;
  final height;
  final width;
  const ImageSwipe({Key? key, this.imageList, this.height, this.width})
      : super(key: key);

  @override
  _ImageSwipeState createState() => _ImageSwipeState();
}

class _ImageSwipeState extends State<ImageSwipe> {
  int selectedPage = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          PageView(
            onPageChanged: (num) {
              setState(() {
                selectedPage = num;
              });
            },
            children: [
              for (var i = 0; i < widget.imageList!.length; i++)
                Padding(
                  padding:
                      const EdgeInsets.only(right: 8.0, bottom: 10, top: 10),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: CachedNetworkImage(
                        imageUrl: widget.imageList![i] ?? "No Image Found",
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CupertinoActivityIndicator(),
                        errorWidget: (context, url, error) =>
                            Icon(Iconsax.image),
                      )),
                ),
            ],
          ),
          Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.imageList!.length; i++)
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          shape: BoxShape.rectangle,
                          color: selectedPage == i
                              ? Colors.white.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.5)),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 6,
                      width: selectedPage == i ? 23 : 9,
                    )
                ],
              ))
        ],
      ),
    );
  }
}
