import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatefulWidget {
  const ImageView({Key? key, required this.images, required this.index}) : super(key: key);
  final List images;
  final int index;

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  late int index;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      index = widget.index;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: FloatingActionButton(
              onPressed: () {
                if (index == 0) {
                  index = widget.images.length - 1;
                } else {
                  index--;
                }
                setState(() {});
              },
              heroTag: 1,
              child: const Center(child: Icon(Icons.arrow_back_ios)),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              if (index == widget.images.length - 1) {
                index = 0;
              } else {
                index++;
              }
              setState(() {});
            },
            heroTag: 2,
            child: const Center(child: Icon(Icons.arrow_forward_ios)),
          ),
        ],
      ),
      body: PhotoView(
        maxScale: 0.5,
        minScale: 0.5,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        imageProvider: NetworkImage(
          widget.images[index],
        ),
      ),
    );
  }
}
