import 'dart:convert';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:minitwitter_app/homePage.dart';
import 'package:minitwitter_app/utils/variables.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

/*

This page is for registering new users and is being called from navigation page.
Once a user has been registered, his credentials are save in the server using the
WebAPI and he is being directed to the home page.

 */

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var _usernameController = TextEditingController();
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();

  /*
  For indicating if the user agreed to the terms of service.
  The checkbox is empty or selected, dependes on this variable
  */
  bool _hasAgreed = false;


  /*
  Since using keyboard controllers, should dispose them.
  */
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /*
  This function is called when the user presses the checkbox.
  Negates the _hasAgreed variable and therefore changing the checkbox icon.
  */
  agreeDisagree() {
    setState(() {
      _hasAgreed = !_hasAgreed;
    });
  }

  /*
  This function is called when the user presses the register button.
  First, the function ensures that the input is valid and then connects
  to the server for authentication.
   */
  signUp(String username, String email, String password) async {
    // if entered username in valid
    if (username.length < 4 || username.length > 20 || username.contains(" ")) {
      Flushbar(
        message: "Username must have 4-20 characters without spaces",
        duration: Duration(seconds: 3),
      )..show(context);
      return;
    }

    // if entered email in valid, using valid email regex.
    final validEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!validEmail.hasMatch(email)) {
      Flushbar(
        message: "Please enter a valid Email",
        duration: Duration(seconds: 3),
      )..show(context);
      return;
    }

    // if entered password is valid
    if (password.length < 4 || password.length > 20 || password.contains(" ")) {
      Flushbar(
        message: "Password must have 4-20 characters without spaces",
        duration: Duration(seconds: 3),
      )..show(context);
      return;
    }

    // if hasn't agreed to terms of service.
    if (!_hasAgreed) {
      Flushbar(
        message: "Please agree to Terms of Policy",
        duration: Duration(seconds: 3),
      )..show(context);
      return;
    }

    // connect to the Web API using http post
    Map data = {
      "UserName": username,
      "Email": email,
      "Password": password,
      "ProfilePicPath": exampleImage,
      "Bio": "",
    };

    var response = await http.post(baseUrl + "/api/register",
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: json.encode(data));

    // if register denied, print the reason
    if (response.statusCode != 200) {
      Flushbar(
        message: json.decode(response.body),
        duration: Duration(seconds: 3),
      )..show(context);
    } else {
      // register completed - store username in device memory and go to home page.
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 100),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Image.asset(
                    "images/logo.png",
                    height: 64,
                    width: 64,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Create An Account",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(
                  height: 20,
                ),
                Text("Register",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    )),
                SizedBox(
                  height: 50,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Username",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        prefixIcon: Icon(Icons.person)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Email",
                        hintText: "you@email.com",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        prefixIcon: Icon(Icons.email)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        prefixIcon: Icon(Icons.lock)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () => signUp(_usernameController.text,
                      _emailController.text, _passwordController.text),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 20, right: 20),
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: Text(
                          "Register",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => agreeDisagree(),
                      child: _hasAgreed
                          ? Icon(Icons.check_box_outlined)
                          : Icon(Icons.check_box_outline_blank),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "I agree to",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                        onTap: () => _termsPopUp(context),
                        child: Row(
                          children: [
                            Text(
                              "Terms of Policy",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.lightBlue,
                                  decoration: TextDecoration.underline),
                            ),
                          ],
                        ))
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login())),
                        child: Text(
                          "Log in",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.lightBlue,
                              decoration: TextDecoration.underline),
                        ))
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

void _termsPopUp(context) {
  Alert(
      context: context,
      title: "Terms of Policy",
      content: Text(
          "Bla bla bla bla bla bla bla\n"
          "bla bla bla bla bla\n",
          style: TextStyle(fontSize: 9)),
      buttons: [
        DialogButton(
          child: Text(
            "AGREE",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
        )
      ]).show();
}
