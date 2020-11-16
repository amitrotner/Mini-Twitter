import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:minitwitter_app/utils/google_cloud_api.dart';
import 'package:minitwitter_app/utils/variables.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login.dart';
import 'friendsList.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

/*
This page handles the user profile.
Displaying user profile picture, bio, number of followers and followees, and
showing tweets made by the user.
*/
class _ProfilePageState extends State<ProfilePage> {

  StreamController _streamController = StreamController(); // A stream controller for user tweets.
  Timer _timer; // A timer for checking the server for new tweets.

  String _username;
  String _profilePicPath;
  String _userBio;
  int _numberOfFollowers;
  int _numberOfFollowees;

  bool _retrievedData = false;

  var _userBioController = TextEditingController();

  // for uploading new profile pic
  File _newProfileImagePath;
  String _newProfileImageName;
  CloudApi _api; // API to Google Cloud Storage

  /*
  Init _api according to credentials.json.
   */
  @override
  void initState() {
    super.initState();
    rootBundle.loadString("assets/credentials.json").then((json) {
      _api = CloudApi(json);
    });

    getFriends();
    getUserTweets();

    //Check the server every 1 second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => getUserTweets());

    super.initState();
  }

  /*
  Since using a keyboard controller, should dispose it.
  */
  @override
  void dispose() {
    //cancel the timer
    if (_timer.isActive) _timer.cancel();
    _retrievedData = false;
    _userBioController.dispose();
    super.dispose();
  }

  // Fetching current username saved in device memory.
  getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username");
    });
  }

  // Gets user profile picture from API
  getProfilePic() async {
    // await getUsername(); // ensure _username is not null
    var response = await http.get(
      baseUrl + "/api/profilepic?username=$_username",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    setState(() {
      _profilePicPath = jsonDecode(response.body).toString();
    });
  }

  // Sets a new profile picture by new picture url
  setProfilePic(String newUrl) async {
    //await getUsername(); // ensure _username is not null
    await http.post(baseUrl + "/api/profilepic?username=$_username",
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
            },
            body: json.encode(newUrl));
    setState(() {
      _profilePicPath = newUrl;
    });
  }

  // Gets user bio from API
  getUserBio() async {
    var response = await http.get(
      baseUrl + "/api/userbio?username=$_username",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    setState(() {
      _userBio = jsonDecode(response.body).toString() != ""
          ? jsonDecode(response.body).toString()
          : null;
      _userBioController.text = _userBio;
    });
  }

  // Sets a new user bio
  setUserBio(String newBio) async {
    await http.post(baseUrl + "/api/userbio?username=$_username",
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: json.encode(newBio));
    setState(() {
      _userBio = newBio != "" ? newBio : null;
    });
  }

  // Get user friends
  getFriends() async {
    await getUsername(); // first get current username
    await getProfilePic();
    await getUserBio();

    var response = await http.get(
      baseUrl + "/api/userfriends?username=$_username",
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

  // Show only tweets made by the user
  getUserTweets() async {
    await getUsername(); // ensure username is not null
    var response = await http.get(
      baseUrl + "/api/usertweetsstream?username=$_username",
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

  // Log out user from the app
  logOut() async {
    // delete username from device memory
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("username");
    await Future.delayed(Duration(seconds: 2));

    // remove all routes and get back to navigation page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => NavigationPage(),
      ),
      (Route route) => false,
    );
  }

  // upload a new profile picture
  pickNewProfilePic(ImageSource imageSource) async {
    final image = await ImagePicker().getImage(source: imageSource);
    setState(() {
      _newProfileImagePath = File(image.path);
      _newProfileImageName = image.path.split("/").last;
    });
    final newProfileUrl = await uploadImage(); // upload to google cloud storage
    await setProfilePic(newProfileUrl); // set in database
    Navigator.pop(context);
  }

  // upload an image to google cloud and return the download link
  Future<String> uploadImage() async {
    final response = await _api.save(
        _newProfileImageName, _newProfileImagePath.readAsBytesSync());
    return response.downloadLink.toString();
  }

  /*
  When pressing the profile image icon, opens a options menu for uploading a new image.
  */
  profilePicOptionsDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                  child: Text("Edit Profile Picture",
                      style: TextStyle(fontSize: 20))),
              SimpleDialogOption(
                  onPressed: () => pickNewProfilePic(ImageSource.gallery),
                  child: Text("Select image from gallery",
                      style: TextStyle(fontSize: 16))),
              SimpleDialogOption(
                  onPressed: () => pickNewProfilePic(ImageSource.camera),
                  child:
                      Text("Take a picture", style: TextStyle(fontSize: 16))),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(fontSize: 16))),
            ],
          );
        });
  }

  /*
  When pressing the edit icon, opens a options menu for setting a new bio.
  */
  userBioOptionsDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              Center(
                child: SimpleDialogOption(
                    child:
                        Text("Edit User Bio", style: TextStyle(fontSize: 20))),
              ),
              SimpleDialogOption(
                child: Column(
                  children: [
                    TextField(
                      maxLines: null,
                      maxLength: 120,
                      controller: _userBioController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Enter a new bio",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          prefixIcon: Icon(Icons.edit)),
                    ),
                    InkWell(
                      onTap: () {
                        setUserBio(_userBioController.text);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Set a new Bio",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  ],
                ),
              ),
              Center(
                child: SimpleDialogOption(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(fontSize: 16))),
              ),
            ],
          );
        });
  }

  /*
  When pressing the setting icon, opens a options menu for logging out.
  */
  settingsOptionsDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              Center(
                child: SimpleDialogOption(
                    onPressed: () => {},
                    child: Text("Log out",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              Row(
                children: [
                  SimpleDialogOption(
                      onPressed: () => logOut(),
                      child: Text("Yes", style: TextStyle(fontSize: 16))),
                  SizedBox(
                    width: 100,
                  ),
                  SimpleDialogOption(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel", style: TextStyle(fontSize: 16))),
                ],
              ),
            ],
          );
        });
  }

  // Like a tweet by tweet id. Connects to the API for increasing the likes counter.
  likePost(int tweetId) async {
    await http.post(
      baseUrl + "/api/liketweet?username=$_username&tweet_id=$tweetId",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
  }

  /*
  Returns true if the user liked the tweet by tweet ID and else returns false.
  The like button icon is set according to the return value.
  */
  Future<bool> hasLiked(int tweetId) async {
    var response = await http.get(
      baseUrl + "/api/liketweet?username=$_username&tweet_id=$tweetId",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );

    if (response.body == "true") return Future<bool>.value(true);
    return Future<bool>.value(false);
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

  @override
  Widget build(BuildContext context) {
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
                          top: MediaQuery.of(context).size.height / 28,
                          left: MediaQuery.of(context).size.width / 1.11),
                      child: PopupMenuButton<int>(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: InkWell(
                              onTap: () => settingsOptionsDialog(),
                              child: Text(
                                "Log Out",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                        icon: Icon(Icons.settings, color: Colors.white),
                        offset: Offset(0, 100),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 6,
                        left: MediaQuery.of(context).size.width / 2 - 64,
                      ),
                      child: CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(_profilePicPath),
                          child: InkWell(
                            onTap: () => profilePicOptionsDialog(),
                            child: Container(
                              alignment: Alignment.bottomRight,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white,
                                child: (Icon(Icons.camera_alt)),
                              ),
                            ),
                          )),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 2.7),
                      child: Column(
                        children: [
                          Text(
                            _username != null ? _username : " ",
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 8,
                              right: MediaQuery.of(context).size.width / 8,
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => userBioOptionsDialog(),
                                    child: Icon(Icons.edit),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Flexible(
                                    child: _userBio != null
                                        ? Text(
                                            _userBio,
                                            style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.black),
                                            overflow: TextOverflow.visible,
                                          )
                                        : Text(
                                            "Enter user bio..",
                                            style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.black),
                                          ),
                                  ),
                                ],
                              ),
                            ),
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
                                                FriendsList(_username, "followees"))),
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
                                  Center(
                                    child: Text(
                                      "Followers",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FriendsList(_username, "followers"))),
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
                            "My Tweets:",
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
