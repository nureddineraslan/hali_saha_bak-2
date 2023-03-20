import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/comment.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    Key? key,
    required this.comment,
  }) : super(key: key);

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: comment.userProfilePicUrl != null ? NetworkImage(comment.userProfilePicUrl!) : null,
            child: comment.userProfilePicUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.username,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    comment.message,
                    style: const TextStyle(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: Wrap(
              children: [
                for (var i = 0; i < comment.rating; i++)
                  const Icon(
                    Icons.star,
                    size: 12,
                    color: Colors.grey,
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
