import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class RecipeImageHero extends StatelessWidget {
  const RecipeImageHero({super.key, required this.storageUrl});

  final String storageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: PhotoView(
        imageProvider: NetworkImage(storageUrl),
        heroAttributes: PhotoViewHeroAttributes(tag: storageUrl),
      ),
    );
  }
}
