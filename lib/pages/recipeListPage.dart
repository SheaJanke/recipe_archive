import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_archive/components/recipeListItem.dart';
import 'package:recipe_archive/pages/recipeEditPage.dart';

import '../models/recipe.dart';

bool contains(String value, String target) {
  return value.toLowerCase().contains(target.toLowerCase());
}

class RecipeListPage extends StatefulWidget {
  RecipeListPage({super.key, required this.user});

  final User user;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  List<String> _tagFilters = [];

  @override
  Widget build(BuildContext context) {
    void _navigateToRecipePage(Recipe recipe) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeEditPage(
            user: widget.user,
            recipe: recipe,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: 'Logout',
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Recipe Archive',
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
      ),
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: EdgeInsets.all(8),
        child: StreamBuilder(
          stream: widget.db
              .collection('users')
              .doc(widget.user.uid)
              .collection('recipes')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),
              );
            }

            List<Recipe> recipes = snapshot.data!.docs
                .map((doc) => Recipe.fromFirestore(doc, null))
                .toList();

            List<String> uniqueTags = List.empty(growable: true);
            for (var recipe in recipes) {
              for (var tag in recipe.tags) {
                if (!uniqueTags.contains(tag)) {
                  uniqueTags.add('#$tag');
                }
              }
            }

            return Column(
              children: [
                Autocomplete(
                  onSelected: (option) {
                    if (option is Recipe) {
                      _navigateToRecipePage(option);
                    }
                  },
                  displayStringForOption: (option) {
                    if (option is Recipe) {
                      return option.name;
                    }
                    return option.toString();
                  },
                  optionsBuilder: (TextEditingValue searchValue) {
                    if (searchValue.text.isEmpty) {
                      return List<Object>.empty();
                    }
                    var matchingTags = uniqueTags
                        .where((tag) => contains(tag, searchValue.text));
                    var matchingRecipes = recipes.where(
                        (recipe) => contains(recipe.name, searchValue.text));
                    return [...matchingRecipes, ...matchingTags];
                  },
                ),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 8);
                    },
                    itemCount: recipes.length,
                    itemBuilder: (ctx, i) =>
                        RecipeListItem(widget.user, recipes[i]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeEditPage(
                user: widget.user,
                recipe: Recipe(),
              ),
            ),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
