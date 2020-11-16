import 'dart:convert';
import 'dart:io';
import 'package:minitwitter_app/utils/google_cloud_api.dart';
import 'package:minitwitter_app/utils/variables.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/*
This class is for posting a new tweet.
 */

class AddTweet extends StatefulWidget {
  @override
  _AddTweetState createState() => _AddTweetState();
}

class _AddTweetState extends State<AddTweet> {

  TextEditingController _tweetController = TextEditingController();

  File _imagePath; // The path of the image uploaded
  String _imageName; // The name of the image uploaded
  CloudApi _api; // API to Google Cloud Storage
  bool _isUploading = false; // for showing progress indicator when posting the tweet

  /*
  Init _api according to credentials.json
   */
  @override
  void initState() {
    super.initState();
    rootBundle.loadString("assets/credentials.json").then((json) {
      _api = CloudApi(json);
    });
  }

  /*
  Since using keyboard controller, should dispose it.
  */
  @override
  void dispose() {
    _tweetController.dispose();
    super.dispose();
  }

  /*
  Picking and image according to image source - gallery/camera.
  Once picked, sets _imagePath and _imageName according to image.
  */
  pickImage(ImageSource imageSource) async {
    final image = await ImagePicker().getImage(source: imageSource);
    setState(() {
      _imagePath = File(image.path);
      _imageName = image.path.split("/").last; // image name is the last string
    });
    Navigator.pop(context);
  }

  /*
  Uploads the image picked to Google Cloud Storage.
  Returns the download link.
  */
  Future<String> uploadImage() async {
    final response = await _api.save(_imageName, _imagePath.readAsBytesSync());
    return response.downloadLink.toString();
  }

  /*
  When pressing the add image icon, opens a options menu for selecting the image source.
  */
  selectPhotoOptions() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                  child: Text("Add a photo", style: TextStyle(fontSize: 20))),
              SimpleDialogOption(
                  onPressed: () => pickImage(ImageSource.gallery),
                  child: Text("Select image from gallery",
                      style: TextStyle(fontSize: 16))),
              SimpleDialogOption(
                  onPressed: () => pickImage(ImageSource.camera),
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
  This function is called when the user presses the post button.
  First, the function ensures that the input is valid and then connects
  to the server for posting the tweet.
  */
  postTweet() async {
    if(_tweetController.text.isEmpty) {
      Flushbar(
        message: "Tweets must have at least one character",
        duration: Duration(seconds: 3),
      )
        ..show(context);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");

    // if the tweet contains an image then upload it to Google Cloud
    String url = _imagePath != null ? await uploadImage() : null;

    // connect to the Web API using http post
    Map data = {
      "UserName": username,
      "Tweet": _tweetController.text,
      "Imagepath": url
    };

    await http.post(baseUrl + "/api/posttweet",
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: json.encode(data));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => selectPhotoOptions(),
          child: Icon(Icons.photo, size: 32),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                size: 32,
                color: Colors.lightBlue,
              )),
          centerTitle: true,
          title: Text(
            "Add Tweet",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          actions: [
            InkWell(
                onTap: () => postTweet(),
                child: Center(
                  child: Text(
                    "Post",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                )),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: _isUploading == false
            ? Column(children: [
                Expanded(
                  child: TextFormField(
                    controller: _tweetController,
                    maxLines: null,
                    maxLength: 120,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "What's on your mind?",
                      labelStyle: TextStyle(fontSize: 20),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                _imagePath == null
                    ? Container()
                    : MediaQuery.of(context).viewInsets.bottom > 0
                        ? ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.2), BlendMode.dstIn),
                            child: Image(
                                width: 200,
                                height: 200,
                                image: FileImage(_imagePath)),
                          )
                        : Image(
                            width: 200,
                            height: 200,
                            image: FileImage(_imagePath),
                          ),
                SizedBox(
                  height: 100,
                ),
              ])
            : Center(
                child: Column(children: [
                  SizedBox(
                    height: 150,
                  ),
                  CircularProgressIndicator(),
                  Text(
                    "Posting...",
                    style: TextStyle(fontSize: 24, color: Colors.black),
                  )
                ]),
              ));
  }
}
