import 'dart:convert';
import 'package:minitwitter_app/profile/viewUser.dart';
import 'package:minitwitter_app/utils/variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

/*
The page handles the users search.
Displays users matching the search field.
*/
class _SearchPageState extends State<SearchPage> {
  var _searchResultsList;

  // Search user by username
  searchUser(String username) {
    var response = http.get(
      baseUrl + "/api/searchusers?searchfield=$username",
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );

    setState(() {
      _searchResultsList = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                hintText: "Search Users",
                hintStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
              onChanged: searchUser,
            )),
        body: _searchResultsList == null
            ? Center(
                child: Text(
                "Search users...",
                style: TextStyle(fontSize: 20),
              ))
            : FutureBuilder(
                future: _searchResultsList,
                builder: (BuildContext context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var searchData = jsonDecode(snapshot.data.body);
                  searchData = json.decode(searchData);
                  return ListView.builder(
                    itemCount: searchData.length,
                    itemBuilder: (BuildContext context, int index) {
                      var searchValue = searchData[index];
                      return Container(
                        height: 100,
                        child: Card(
                          elevation: 8.0,
                          child: Container(
                            margin: EdgeInsets.all(20),
                            child: InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ViewUser(searchValue["UserName"]))),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(
                                      searchValue["ProfilePicPath"]),
                                  radius: 26,
                                ),
                                title: Text(
                                  searchValue["UserName"],
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 24),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ));
  }
}
