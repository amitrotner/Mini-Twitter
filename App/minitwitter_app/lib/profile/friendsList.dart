import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:minitwitter_app/profile/viewUser.dart';
import 'package:minitwitter_app/utils/variables.dart';
import 'package:http/http.dart' as http;


/*
This class displays a list of a user followers or followees.
Is called when
*/

class FriendsList extends StatefulWidget {
  final String _user; // the username whose list to display
  final String _select; // the select option - followers or followees.

  FriendsList(this._user, this._select);

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  var _friendList; // A variable containing the list

  @override
  void initState() {
    super.initState();
    getFriends();
  }

  Future<dynamic> getFriends() async {
    var response = http.post(
      baseUrl +
          "/api/userfriends?username=${widget._user}&select=${widget._select}",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );

    setState(() {
      _friendList = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text(widget._select == "followees"
                ? "Following List"
                : "Followers List")),
        body: FutureBuilder(
          future: _friendList,
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var friendData = jsonDecode(snapshot.data.body);
            friendData = json.decode(friendData);
            return ListView.builder(
              itemCount: friendData.length,
              itemBuilder: (BuildContext context, int index) {
                var friendValue = friendData[index];
                return Container(
                  height: 70,
                  child: Card(
                    elevation: 8.0,
                    child: ListTile(
                      title: InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewUser(friendValue))),
                        child: Text(
                          friendValue,
                          style: TextStyle(color: Colors.black, fontSize: 24),
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
