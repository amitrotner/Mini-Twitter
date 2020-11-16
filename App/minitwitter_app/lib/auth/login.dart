import 'dart:convert';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:minitwitter_app/homePage.dart';
import 'file:///C:/Users/User/source/repos/MiniTwitter/App/minitwitter_app/lib/auth/signUp.dart';
import 'package:minitwitter_app/utils/variables.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/*

This page is the first page of the app - being called from main page.
One can login via this page and be navigated to the home page.
Unregistered users can navigate to the sign up page for registration.

Once a user has been logged in, his username is saved in the device for enabling
fast login in the next time.

 */

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  bool _loading =
      true; // for showing progress bar indicator when when fetching last login username from device
  bool _isSigned = false; // for fast login in next times

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn();
  }

  /*
  If loading username from device memory - show circular progress indicator.
  If logged in from last time, move to HomePage, else login.
   */
  @override
  Widget build(BuildContext context) {
    return _loading == false
        ? Scaffold(
            body: _isSigned == false ? Login() : HomePage(),
          )
        : Center(child: CircularProgressIndicator());
  }

  /*
  Check if already logged in using SharedPreferences.
   */
  checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    setState(() {
      _isSigned = username == null ? false : true;
      _loading = false;
    });
  }
}

/*

This class is for logging in users and is being called from navigation page.
Once a user has been logged in, his credentials are save in the server using the
WebAPI and he is being directed to the home page.

 */

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var _usernameController = TextEditingController();
  var _passwordController = TextEditingController();


  /*
  Since using keyboard controllers, should dispose them.
  */
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /*
  This function is called when the user presses the login button.
  First, the function ensures that the input is valid and then connects
  to the server for authentication.
   */
  login(String username, String password) async {
    // if entered username in valid
    if (username.length < 4 || username.length > 20 || username.contains(" ")) {
      Flushbar(
        message: "Username must have 4-20 characters without spaces",
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

    // connect to the Web API using http post
    Map data = {"UserName": username, "Password": password};

    var response = await http.post(baseUrl + "/api/login",
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: json.encode(data));

    // if login denied, show the reason
    if (response.statusCode != 200) {
      Flushbar(
        message: json.decode(response.body),
        duration: Duration(seconds: 3),
      )..show(context);
    } else {
      // once login succeeded, store the username in the device memory and go to home page.
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', json.decode(response.body));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
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
              Text("Welcome to Mini Twitter!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  )),
              SizedBox(
                height: 20,
              ),
              Text("Please Login",
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
                onTap: () =>
                    login(_usernameController.text, _passwordController.text),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 20, right: 20),
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: Text(
                        "Login",
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
                  Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignUp())),
                      child: Text(
                        "Create one!",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.lightBlue,
                            decoration: TextDecoration.underline),
                      ))
                ],
              )
            ],
          ),
        ));
  }
}
