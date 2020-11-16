import 'dart:typed_data';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:gcloud/storage.dart';
import 'package:mime/mime.dart';

class CloudApi {
  final auth.ServiceAccountCredentials _credentials;
  auth.AutoRefreshingAuthClient _client;

  CloudApi(String json)
    : _credentials = auth.ServiceAccountCredentials.fromJson(json);

  Future<ObjectInfo> save(String name, Uint8List imgBytes) async {
    if (_client == null)
      _client = await auth.clientViaServiceAccount(_credentials, Storage.SCOPES);

    var storage = Storage(_client, "Image Upload to Google Storage");
    var bucket = storage.bucket("tweets-and-profile-pics");

    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    final type = lookupMimeType(name);
    return await bucket.writeBytes(name, imgBytes, metadata: ObjectMetadata(
      contentType: type,
      custom: {
        "timestamp" : "$timeStamp",
      }
    ));
  }
}