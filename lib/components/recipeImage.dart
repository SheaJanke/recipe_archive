import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:recipe_archive/components/recipeImageHero.dart';

class RecipeImage extends StatelessWidget {
  RecipeImage({super.key, required this.imgUrl});

  final String imgUrl;
  final Reference storageRef = FirebaseStorage.instance.ref();
  late final Future<String> storageUrl =
      storageRef.child(imgUrl).getDownloadURL();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: storageUrl,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SizedBox(
              width: 200,
              height: 200,
              child: GestureDetector(
                child: Hero(
                  child: Image.network(snapshot.data!),
                  tag: snapshot.data!,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeImageHero(storageUrl: snapshot.data!)
                  ),
                ),
              ),
            );
          }
          return CircularProgressIndicator();
        });
  }
}
