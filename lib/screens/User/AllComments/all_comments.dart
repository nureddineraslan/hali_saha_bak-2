import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/comment.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';

import '../../../widgets/comment_widget.dart';

class AllComments extends StatefulWidget {
  const AllComments({Key? key, required this.haliSaha}) : super(key: key);

  final HaliSaha haliSaha;

  @override
  State<AllComments> createState() => _AllCommentsState();
}

class _AllCommentsState extends State<AllComments> {
  List<Comment> comments = [];
  bool commentsGet = false;

  Future<void> getComments() async {
    comments = await FirestoreService().getHaliSahaComments(widget.haliSaha);
    setState(() => commentsGet = true);
  }

  @override
  void initState() {
    super.initState();
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Yorumlar'),
      ),
      body: Builder(builder: (context) {
        if (!commentsGet) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (comments.isEmpty) {
          return const Center(child: Text('Henüz yorum yapılmamış'));
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              Comment comment = comments[index];
              return CommentWidget(comment: comment);
            },
          ),
        );
      }),
    );
  }
}
