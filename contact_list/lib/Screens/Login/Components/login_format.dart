// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:contact_list/Screens/User_Contact_List/user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Components/already_have_account.dart';
import '../../../constant.dart';
import '../../SignUp/sign_up_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String useremail = "";
  String userpass = "";
  final _auth = FirebaseAuth.instance;
  bool isLoading = true;
  final formKey = GlobalKey<FormState>();

  Future<void> login(String email, String pass) async {
    try {
      final user =
          await _auth.signInWithEmailAndPassword(email: email, password: pass);
      setState(() {
        isLoading = false;
      });
      if (user != null) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('useremail', email);
        pref.setString('userid', user.user!.uid);
        // print("user id = ${user.user!.uid}");
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => UserScreen(
                      userid: user.user!.uid,
                    )),
            (route) => false);
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), side: BorderSide.none),
            title: const Text(
              "Oops!",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black,
                height: 1.5,
              ),
            ),
            content: Text(
              "${e}".replaceRange(0, 7, '').replaceAll(
                    '}',
                    '',
                  ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            actions: [
              TextButton(
                child: const Text(
                  "Ok",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );

      print("exception coming from login " + e.toString());
    }
    // Navigator.of(context).pop();
  }

  @override
  void initState() {
    delay();
    super.initState();
  }

  void delay() async {
    await Future.delayed(Duration(seconds: 6));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            validator: (val) {
              if (RegExp(r"[a-zA-Z0-9.! #$%&'*+/=? ^_`{|}~-]+@[a-zA-Z0-9-]")
                  .hasMatch(val!)) {
                useremail = val;
                return null;
              }
              return "please enter valid email ! ";
            },
            decoration: const InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              validator: (val) {
                userpass = val!;
                return val.length < 8 ? "Enter Password 8 Character" : null;
              },
              decoration: const InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  login(useremail, userpass);
                }
              },
              child: Text(
                "Login".toUpperCase(),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
