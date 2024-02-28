import 'package:flutter/material.dart';
import 'package:instagram_clone/exceptions/custom_exception.dart';
import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/providers/feed/feed_provider.dart';
import 'package:instagram_clone/providers/feed/feed_state.dart';
import 'package:instagram_clone/utils/logger.dart';
import 'package:instagram_clone/widgets/error_dialog_widget.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final FeedProvider feedProvider;

  @override
  void initState() {
    super.initState();
    feedProvider = context.read<FeedProvider>();
    feedProvider.getFeedList();
  }



  @override
  Widget build(BuildContext context) {
    logger.d(context.read<FeedState>().feedList);
    return const Placeholder();
  }
}
