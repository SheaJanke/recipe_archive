import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_archive/components/recipeListItem.dart';
import 'package:recipe_archive/components/tagList.dart';
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
  late TextEditingController _searchController;
  List<String> _allTags = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  void addValueToTagFilters(String newTag) {
    if (!_tagFilters.contains(newTag)) {
      setState(() {
        _tagFilters.add(newTag);
      });
    }
  }

  void deleteValueFromTagFilters(String deleteTag) {
    setState(() {
      _tagFilters.remove(deleteTag);
    });
  }

  @override
  Widget build(BuildContext context) {
    void _navigateToRecipePage(Recipe recipe) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeEditPage(
            user: widget.user,
            recipe: recipe,
            allTags: _allTags,
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
      body: StreamBuilder(
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
                uniqueTags.add(tag);
              }
            }
          }
          Future.delayed(Duration.zero, () {
            setState(() {
              _allTags = uniqueTags;
            });
          });

          List<Recipe> filteredRecipes = recipes
              .where(
                (recipe) => _tagFilters.every(
                  (tag) => recipe.tags.contains(tag),
                ),
              )
              .toList();

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Autocomplete(
                      onSelected: (option) {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                        if (option is Recipe) {
                          _navigateToRecipePage(option);
                        } else {
                          addValueToTagFilters(option.toString());
                        }
                      },
                      displayStringForOption: (option) {
                        if (option is Recipe) {
                          return option.name;
                        }
                        var tag = option.toString();
                        return '#$tag';
                      },
                      optionsBuilder: (TextEditingValue searchValue) {
                        if (searchValue.text.isEmpty) {
                          return List<Object>.empty();
                        }
                        var matchingTags = uniqueTags.where(
                            (tag) => contains('#$tag', searchValue.text));
                        var matchingRecipes = recipes.where((recipe) =>
                            contains(recipe.name, searchValue.text));
                        return [...matchingRecipes, ...matchingTags];
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) {
                        _searchController = fieldTextEditingController;
                        return TextField(
                          autofocus: false,
                          controller: fieldTextEditingController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              contentPadding: EdgeInsets.all(16),
                              isDense: true,
                              hintText: 'Search Recipe / Filter By Tag',
                              prefixIcon: Icon(Icons.search)),
                          focusNode: fieldFocusNode,
                        );
                      },
                    ),
                    _tagFilters.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 8, left: 8, right: 8),
                            child:
                                TagList(tags: _tagFilters, onDeleteTag: deleteValueFromTagFilters),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 8);
                    },
                    itemCount: filteredRecipes.length,
                    itemBuilder: (ctx, i) => RecipeListItem(
                      widget.user,
                      filteredRecipes[i],
                      _allTags,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeEditPage(
                user: widget.user,
                recipe: Recipe(),
                allTags: _allTags,
              ),
            ),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
