import 'package:flutter/material.dart';

class Likebtn extends StatefulWidget {
  final int likescount;
  final void Function()? onTap;

  Likebtn({Key? key, required this.onTap, required this.likescount})
      : super(key: key);

  @override
  State<Likebtn> createState() => _LikebtnState();
}

class _LikebtnState extends State<Likebtn> {
  bool isLiked = false;
  String likeid = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              size: 28,
              color: isLiked
                  ? Colors.redAccent
                  : const Color.fromARGB(255, 136, 132, 132),
            ),
          ),
          Text(
            (isLiked ? widget.likescount + 1 : widget.likescount).toString(),
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            width: 12,
          )
        ],
      ),
    );
  }

  void onTap() {
    setState(() {
      isLiked = !isLiked;
    });
    if (isLiked) {
      widget.onTap?.call(); // Call onTap callback when liked
    }
  }
}
