import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:random_string/random_string.dart';

class StorageService {
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  Future<String> uploadImage(File image, {String name = 'unknown', bool profilePicUrl = false}) async {
    String random = '';
    String downloadURL = '';
    String fileName = basename(image.path);

    String path = fileName;

    if (fileName.length < 10) {
      random = randomNumeric(10 - fileName.length);
      path = '$random$fileName';
    }

    String bucketName = profilePicUrl ? 'profilePics' : 'images';

    await storage.ref().child('$bucketName/$name').child(path).putFile(image).then(
          (taskSnapshot) async => downloadURL = await taskSnapshot.ref.getDownloadURL(),
        );

    return downloadURL;
  }
}
