import 'package:flutter/material.dart';

import '../../Constants/constants.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  String email = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                decoration: InputDecoration(
                    fillColor: Color.fromARGB(255, 48, 46, 46),
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
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 10, bottom: 10),
                primary: Colors.lightBlueAccent[200],
              ),
              onPressed: () async {
                if (email.isEmpty || email.contains('@gmail.com') == false) {
                  toastMessage('Please enter a valid email');
                } else {
                  try {
                    await auth
                        .sendPasswordResetEmail(email: email)
                        .then((value) {
                      toastMessage('Password Reset Link Sent to Your Email');
                    }).onError((error, stackTrace) {
                      toastMessage(error.toString());
                    });
                  } catch (e) {
                    toastMessage(e.toString());
                  }
                }
              },
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
