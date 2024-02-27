import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/providers/feed/feed_state.dart';
import 'package:instagram_clone/repositories/feed_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class FeedProvider extends StateNotifier<FeedState> with LocatorMixin{
  FeedProvider() : super(FeedState.init());

  Future<void> uploadFeed({
    required List<String> files,
    required String desc,

}) async {
    String uid = read<User>().uid;
   await read<FeedRepository>().uploadFeed(files: files, desc: desc, uid: uid);
  }
}