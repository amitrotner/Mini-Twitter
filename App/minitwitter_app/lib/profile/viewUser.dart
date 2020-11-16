import 'dart:async';
import 'dart:convert';
import 'package:minitwitter_app/utils/variables.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'friendsList.dart';

/*
This page handles viewing other users profiles.
Displaying user profile picture, bio, number of followers and followees, and
showing tweets made by the user.
*/
class ViewUser extends StatefulWidget {
  final String _username; // the username whose profile to display

  ViewUser(this._username);

  @override
  _ViewUserState createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser> {
  StreamController _streamController = StreamController(); // A stream controller for user tweets.
  Timer _timer; // A timer for checking the server for new tweets.

  String _profilePicPath;
  String _originalUser; // current user logged in
  String _userBio;
  int _numberOfFollowers;
  int _numberOfFollowees;

  bool _isFollowing = false;
  bool _retrievedData = false;

  @override
  void initState() {
    super.initState();
    getFriends();
    getUserTweets();

    //Check the server every 1 second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => getUserTweets());

    super.initState();
  }

  @override
  void dispose() {
    //cancel the timer
    if (_timer.isActive) _timer.cancel();
    _retrievedData = false;
    super.dispose();
  }

  // Fetching current logged in (original) username saved in device memory.
  getOriginalUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _originalUser = prefs.getString("username");
    });
  }

  // Like a tweet by tweet id. Connects to the API for increasing the likes counter.
  likePost(int tweetId) async {
    // await getOriginalUsername(); // ensures original username is not null
    await http.post(
      baseUrl + "/api/liketweet?username=$_originalUser&tweet_id=$tweetId",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
  }

  // Checking in the API if original user is following username and sets _isFollowing accordingly
  hasFollowed() async {
    // await getOriginalUsername(); // ensures original username is not null
    String username = widget._username;
    var response = await http.get(
      baseUrl + "/api/followuser?follower=$_originalUser&followee=$username",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    setState(() {
      _isFollowing = response.body == "true" ? true : false;
    });
  }

  /*
  Returns true if the user liked the tweet by tweet ID and else returns false.
  The like button icon is set according to the return value.
  */
  Future<bool> hasLiked(int tweetId) async {
    var response = await http.get(
      baseUrl + "/api/liketweet?username=$_originalUser&tweet_id=$tweetId",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );

    if (response.body == "true") return Future<bool>.value(true);
    return Future<bool>.value(false);
  }

  // Make original username to follow or unfollow user
  followUnfollow() async {
    // await getOriginalUsername();
    String username = widget._username;
    await http.post(
      baseUrl + "/api/followuser?follower=$_originalUser&followee=$username",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    await hasFollowed(); // change the button text accordingly
    await getFriends(); // count again the number of friends
  }

  // Sharing a tweet. Connects to the API for increasing the shares counter.
  sharePost(int tweetId, String tweet) async {
    Share.text("MiniTwitter", tweet, "test/plain");
    await http.post(
      baseUrl + "/api/sharetweet?tweet_id=$tweetId",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
  }

  // Gets user profile picture from API
  getProfilePic() async {
    String username = widget._username;
    var response = await http.get(
      baseUrl + "/api/profilepic?username=$username",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    setState(() {
      _profilePicPath = jsonDecode(response.body).toString();
    });
  }

  // Gets user bio from API
  getUserBio() async {
    String username = widget._username;
    var response = await http.get(
      baseUrl + "/api/userbio?username=$username",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    setState(() {
      _userBio =
          response.body != "" ? jsonDecode(response.body).toString() : null;
    });
  }

  // Get user friends
  getFriends() async {
    await getOriginalUsername(); // first get original username
    await getProfilePic();
    await getUserBio();
    await hasFollowed();

    String username = widget._username;
    var response = await http.get(
      baseUrl + "/api/userfriends?username=$username",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );

    String _friends = jsonDecode(response.body);
    Map<String, dynamic> friends = json.decode(_friends);

    setState(() {
      _numberOfFollowers = friends["followers"];
      _numberOfFollowees = friends["followees"];
      _retrievedData = true;
    });
  }

  //Show only tweets made by the user
  getUserTweets() async {
    String username = widget._username;
    var response = await http.get(
      baseUrl + "/api/usertweetsstream?username=$username",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    String tweets = jsonDecode(response.body);

    List<dynamic> tweetList = json.decode(tweets);

    //Add your tweets to stream
    _streamController.add(tweetList);
  }

  @override
  Widget build(BuildContext context) {
    String username = widget._username;
    return Scaffold(
        body: _retrievedData == true
            ? SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 4,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.lightBlue, Colors.cyan])),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 22,
                      ),
                      child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back,
                            size: 32,
                            color: Colors.black,
                          )),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 6,
                        left: MediaQuery.of(context).size.width / 2 - 64,
                      ),
                      child: CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(_profilePicPath)),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 2.7),
                      child: Column(
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          username != _originalUser
                              ? InkWell(
                                  onTap: () => followUnfollow(),
                                  child: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      margin:
                                          EdgeInsets.only(left: 20, right: 20),
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.lightBlue,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Center(
                                        child: Text(
                                          _isFollowing ? "Unfollow" : "Follow",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                )
                              : Container(),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 8,
                              right: MediaQuery.of(context).size.width / 8,
                            ),
                            child: _userBio != null
                                ? Text(
                                    _userBio,
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.black),
                                    overflow: TextOverflow.visible,
                                  )
                                : Container(),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Following",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                  InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FriendsList(username, "followees"))),
                                    child: Text(
                                      _numberOfFollowees.toString(),
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Followers",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                  InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FriendsList(username, "followers"))),
                                    child: Text(
                                      _numberOfFollowers.toString(),
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "User Tweets:",
                            style: TextStyle(
                                fontSize: 23,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          //User Tweet Feed
                          StreamBuilder(
                              stream: _streamController.stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                } else {
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final tweetData = snapshot.data[index];
                                        return Card(
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              backgroundImage: NetworkImage(
                                                  tweetData["ProfilePicPath"]),
                                            ),
                                            title: Text(
                                              tweetData["UserName"],
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Column(
                                              children: [
                                                Text(
                                                  tweetData["Tweet"],
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                                if (tweetData["Imagepath"] !=
                                                    null)
                                                  Image(
                                                      image: NetworkImage(
                                                          tweetData[
                                                              "Imagepath"])),
                                                SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        InkWell(
                                                            onTap: () =>
                                                                likePost(
                                                                    tweetData[
                                                                        "Id"]),
                                                            child:
                                                                FutureBuilder(
                                                                    future: hasLiked(
                                                                        tweetData[
                                                                            "Id"]),
                                                                    builder: (BuildContext
                                                                            context,
                                                                        snapshot) {
                                                                      if (!snapshot
                                                                          .hasData)
                                                                        return Icon(
                                                                            Icons
                                                                                .favorite_border_outlined,
                                                                            color:
                                                                                Colors.black);
                                                                      return snapshot
                                                                              .data
                                                                          ? Icon(Icons.favorite,
                                                                              color: Colors
                                                                                  .red)
                                                                          : Icon(
                                                                              Icons.favorite_border_outlined,
                                                                              color: Colors.black);
                                                                    })),
                                                        SizedBox(width: 10),
                                                        Text(
                                                            tweetData[
                                                                    "LikesCount"]
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 18)),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        InkWell(
                                                            onTap: () =>
                                                                sharePost(
                                                                    tweetData[
                                                                        "Id"],
                                                                    tweetData[
                                                                        "Tweet"]),
                                                            child: Icon(
                                                                Icons.share)),
                                                        SizedBox(width: 10),
                                                        Text(
                                                            tweetData[
                                                                    "SharesCount"]
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 18)),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                }
                              }),
                        ],
                      ),
                    )
                  ],
                ))
            : Center(child: CircularProgressIndicator()));
  }
}
