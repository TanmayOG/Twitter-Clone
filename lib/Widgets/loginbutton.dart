import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final title;
  final Function? onPressed;

  const LoginButton({Key? key, this.title, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed as void Function()?,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 48,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xffedaef9),
                Color(0xff81b1FA),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue),
        child:  Center(child: Text(title)),
      ),
    );
  }
}
