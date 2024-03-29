//feed_repository.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/exceptions/custom_exception.dart';
import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:uuid/uuid.dart';

class FeedRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const FeedRepository({
    required this.firebaseStorage,
    required this.firebaseFirestore,


  });

  Future<List<FeedModel>> getFeedList() async {
    try{
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore.collection('feeds').orderBy('createAt',descending: true).get();
      return await Future.wait(snapshot.docs.map((e) async {
        Map<String, dynamic> data = e.data();
        DocumentReference<Map<String, dynamic>> writerDocRef = data['writer'];
        DocumentSnapshot<Map<String, dynamic>> writerSnapshot = await writerDocRef.get();
        UserModel userModel = UserModel.fromMap(writerSnapshot.data()!);
        data['writer'] = userModel;
        return FeedModel.fromMap(data);
      }).toList());
    } on FirebaseException catch (e) {
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }
  }

  Future<void> uploadFeed({
    required List<String> files,
    required String desc,
    required String uid,
  }) async {
    List<String> imageUrls = [];

    try {
      WriteBatch batch = firebaseFirestore.batch();

      String feedId = Uuid().v1();

      // firestore 문서 참조
      DocumentReference<Map<String, dynamic>> feedDocRef
      = firebaseFirestore.collection('feeds').doc(feedId);

      DocumentReference<Map<String, dynamic>> userDocRef
      = firebaseFirestore.collection('users').doc(uid);

      // storage 참조
      Reference ref = firebaseStorage.ref().child('feeds').child(feedId);

      imageUrls = await Future.wait(files.map((e) async {
        String imageId = Uuid().v1();
        TaskSnapshot taskSnapshot = await ref.child(imageId).putFile(File(e));
        return await taskSnapshot.ref.getDownloadURL();
      }).toList());

      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userDocRef.get();
      UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

      FeedModel feedModel = FeedModel.fromMap({
        'uid' : uid,
        'feedId' : feedId,
        'desc' : desc,
        'imageUrls' : imageUrls,
        'likes' : [],
        'likeCount' : 0,
        'commentCount' : 0,
        'createAt' : Timestamp.now(),
        'writer' : userModel,
      });

      batch.set(feedDocRef, feedModel.toMap(userDocRef: userDocRef));

      batch.update(userDocRef, {
        'feedCount': FieldValue.increment(1),
      });

      batch.commit();

    } on FirebaseException catch (e) {
      _deleteImage(imageUrls);
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      _deleteImage(imageUrls);
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }


  }
  void _deleteImage(List<String> imageUrls){
    imageUrls.forEach((element) async {
      await firebaseStorage.refFromURL(element).delete();
    });
  }
}