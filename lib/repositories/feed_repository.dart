//feed_repository.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:uuid/uuid.dart';

class FeedRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const FeedRepository({
    required this.firebaseFirestore,
    required this.firebaseStorage,

  });

  Future<void> uploadFeed({
    required List<String> files,
    required String desc,
    required String uid,
  }) async {
    // uuid 36글자 a+0 32 hypen 4
    String feedId = Uuid().v1();

    // firestore 문서 참조
    DocumentReference<Map<String, dynamic>> feedDocRef = firebaseFirestore
        .collection('feeds').doc(feedId);

    DocumentReference<Map<String, dynamic>> userDocRef = firebaseFirestore
        .collection('users').doc(uid);

    // storage 참조
    Reference ref = firebaseStorage.ref().child('feeds').child(feedId);

    List<String> imageUrls = await Future.wait(files.map((e) async {
      String imageId = Uuid().v1();
      TaskSnapshot taskSnapshot = await ref.child(imageId).putFile(File(e));
      return await taskSnapshot.ref.getDownloadURL();
    }).toList());

    DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userDocRef.get();
    UserModel userModel =UserModel.fromMap(userSnapshot.data()!);

    FeedModel feedModel = FeedModel.fromMap({
      'uid': uid,
      'feedId': feedId,
      'desc': desc,
      'imageUrls': imageUrls,
      'likes': [],
      'likeCount': 0,
      'commentCount': 0,
      'createAt': Timestamp.now(),
      'writer': userModel,
    });

    await feedDocRef.set(feedModel.toMap(userDocRef: userDocRef));

    await userDocRef.update({
      'feedCount' : FieldValue.increment(1),
    });
  }
}