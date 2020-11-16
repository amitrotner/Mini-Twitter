import 'file:///C:/Users/User/source/repos/MiniTwitter/App/minitwitter_app/lib/profile/profile.dart';
import 'file:///C:/Users/User/source/repos/MiniTwitter/App/minitwitter_app/lib/search/search.dart';
import 'file:///C:/Users/User/source/repos/MiniTwitter/App/minitwitter_app/lib/feed/tweets.dart';
import 'package:flutter/material.dart';

/*

This page is the home page of the app.
It includes three pages and has the option to move between them.
The pages are:

1. Tweets page
2. Search page
3. Profile page

The default page when entered is the tweets page.
 */

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List _pagesOptions = [
    TweetsPage(), // 0
    SearchPage(), // 1
    ProfilePage(), // 2
  ];

  int _defaultPage = 0; //default page = tweets

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pagesOptions[_defaultPage],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _defaultPage = index; // move to the page corresponds to index.
          });
        },
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.black,
        currentIndex: _defaultPage,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 32,
            ),
            label: "Tweets",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 32,
            ),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 32,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
