import 'dart:async';
import 'dart:convert';
import 'package:minitwitter_app/profile/viewUser.dart';
import 'package:minitwitter_app/utils/variables.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'addTweet.dart';

class TweetsPage extends StatefulWidget {
  @override
  _TweetsPageState createState() => _TweetsPageState();
}

/*
This page handles the tweets feed.
Displaying tweets tweeted by the user or by users the user follows.
*/
class _TweetsPageState extends State<TweetsPage> {

  StreamController _streamController = StreamController(); // A stream controller for the tweets.
  Timer _timer; // A timer for checking the server for new tweets.

  String _username;
  // CloudApi api;

  @override
  void initState() {
    super.initState();
    /* rootBundle.loadString("assets/credentials.json").then((json) {
      api = CloudApi(json);
    }); */
    setState(() {
      getUsername();
    });

    getTweets();
    //Check the server every 1 seconds
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => getTweets());

    super.initState();
  }

  @override
  void dispose() {
    //cancel the timer
    if (_timer.isActive) _timer.cancel();

    super.dispose();
  }

  // Fetching current username saved in device memory.
  getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username");
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

  /*
  Retrieves tweets made by the user or by users the user follows.
  Add those tweets to the tweet stream.
   */
  Future getTweets() async {
    await getUsername(); // ensure that _username is not null.
    var response = await http.get(
      baseUrl + "/api/tweetstream?username=$_username",
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddTweet())),
        child: Icon(Icons.add, size: 32),
      ),
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "MiniTwitter",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              SizedBox(width: 10),
              Image(
                width: 45,
                height: 45,
                image: AssetImage("images/logo.png"),
              ),
            ],
          )),
      body: StreamBuilder(
          stream: _streamController.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final tweetData = snapshot.data[index];
                    return Card(
                      child: ListTile(
                        leading: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewUser(tweetData["UserName"]))),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage:
                                NetworkImage(tweetData["ProfilePicPath"]),
                          ),
                        ),
                        title: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewUser(tweetData["UserName"]))),
                          child: Text(
                            tweetData["UserName"],
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        subtitle: Column(
                          children: [
                            Text(
                              tweetData["Tweet"],
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            if (tweetData["Imagepath"] != null)
                              Image(
                                  image: NetworkImage(tweetData["Imagepath"])),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                        onTap: () => likePost(tweetData["Id"]),
                                        child: FutureBuilder(
                                            future: hasLiked(tweetData["Id"]),
                                            builder: (BuildContext context,
                                                snapshot) {
                                              if (!snapshot.hasData)
                                                return Icon(
                                                    Icons
                                                        .favorite_border_outlined,
                                                    color: Colors.black);
                                              return snapshot.data
                                                  ? Icon(Icons.favorite,
                                                      color: Colors.red)
                                                  : Icon(
                                                      Icons
                                                          .favorite_border_outlined,
                                                      color: Colors.black);
                                            })),
                                    SizedBox(width: 10),
                                    Text(tweetData["LikesCount"].toString(),
                                        style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                        onTap: () => sharePost(tweetData["Id"],
                                            tweetData["Tweet"]),
                                        child: Icon(Icons.share)),
                                    SizedBox(width: 10),
                                    Text(tweetData["SharesCount"].toString(),
                                        style: TextStyle(fontSize: 18)),
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
    );
  }
}
