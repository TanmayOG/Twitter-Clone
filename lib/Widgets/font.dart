import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const TextStyle usernameF = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.bold,
);
const TextStyle usernamePF = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);
const TextStyle emailPF = TextStyle(fontSize: 14, color: Colors.grey);
const TextStyle captionF = TextStyle(
  fontSize: 13,
);
const TextStyle tweetF = TextStyle(
  fontSize: 15,
);
const TextStyle timeF = TextStyle(fontSize: 11, color: Colors.grey);
const TextStyle followF = TextStyle(fontSize: 12, color: Colors.white);
const TextStyle followPF = TextStyle(fontSize: 13, color: Colors.white);
const TextStyle bioF = TextStyle(fontSize: 13, color: Colors.grey);

getColoredHashtagText(String text, context) {
  if (text.contains('#')) {
    var preHashtag = text.substring(0, text.indexOf('#'));
    var postHashtag = text.substring(text.indexOf('#'));
    var hashTag = postHashtag;
    var other;
    if (postHashtag.contains(' ')) {
      hashTag = postHashtag.substring(0, postHashtag.indexOf(' '));
      other = postHashtag.substring(postHashtag.indexOf(' '));
    }
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(text: preHashtag, style: const TextStyle(fontSize: 14)),
          TextSpan(
              text: hashTag,
              style: const TextStyle(color: Colors.blue, fontSize: 14)),
          TextSpan(text: other != null ? other : ""),
        ],
      ),
    );
  } else {
    return Text(text);
  }
}

class HashtagText extends StatelessWidget {
  final String text;
  const HashtagText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text.contains('#')) {
      var preHashtag = text.substring(0, text.indexOf('#'));
      var postHashtag = text.substring(text.indexOf('#'));
      var hashTag = postHashtag;
      var other;
      if (postHashtag.contains(' ')) {
        hashTag = postHashtag.substring(0, postHashtag.indexOf(' '));
        other = postHashtag.substring(postHashtag.indexOf(' '));
      }
      return RichText(
        maxLines: 3,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(text: preHashtag, style: const TextStyle(fontSize: 12)),
            TextSpan(
                text: hashTag,
                style: const TextStyle(color: Colors.blue, fontSize: 12)),
            TextSpan(
                text: other != null ? other : "",
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    } else {
      return Text(
        text,
        style: captionF,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}
