import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:recipe_archive/components/recipeImageHero.dart';

class RecipeImage extends StatefulWidget {
  RecipeImage({super.key, required this.imgUrl, this.onDeleteImg});

  final String imgUrl;
  final Function(String imgUrl)? onDeleteImg;
  final Reference storageRef = FirebaseStorage.instance.ref();

  @override
  State<RecipeImage> createState() => _RecipeImageState();
}

class _RecipeImageState extends State<RecipeImage> {
  late final Future<String> storageUrl;

  @override
  void initState() {
    super.initState();
    storageUrl = widget.storageRef.child(widget.imgUrl).getDownloadURL();
  }

  void onDeleteImg() {
    if (widget.onDeleteImg != null) {
      widget.onDeleteImg!(widget.imgUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(
          Radius.circular(4),
        ),
      ),
      child: FutureBuilder(
          future: storageUrl,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  GestureDetector(
                    child: Hero(
                      child: CachedNetworkImage(
                        imageUrl: snapshot.data!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      tag: snapshot.data!,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RecipeImageHero(storageUrl: snapshot.data!)),
                    ),
                  ),
                  widget.onDeleteImg != null
                      ? Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.red.shade600),
                          margin: EdgeInsets.all(4),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: onDeleteImg,
                            icon: Icon(Icons.close),
                            iconSize: 20,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              );
            }
            return CircularProgressIndicator();
          }),
    );
  }
}
