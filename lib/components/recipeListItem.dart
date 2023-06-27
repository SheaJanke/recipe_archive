import 'package:firebase_auth/firebase_auth.dart';

import '../models/recipe.dart';
import 'package:flutter/material.dart';

import '../pages/recipeEditPage.dart';

import 'dart:math';

const borderRadius = BorderRadius.all(Radius.circular(8));
const maxTagsDisplayed = 3;

class RecipeListItem extends StatelessWidget {
  const RecipeListItem(this.user, this.recipe, {super.key});

  final User user;
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: borderRadius,
      elevation: 2,
      shadowColor: Colors.blueGrey,
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeEditPage(
              user: user,
              recipe: recipe,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        tileColor: Colors.white,
        title: Text(recipe.name, style: TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.chevron_right),
        subtitle: SizedBox(
          height: 36,
          child: ListView.separated(
              itemBuilder: (ctx, i) {
                String tag = recipe.tags[i];
                int numExtraTags = recipe.tags.length - maxTagsDisplayed;
                return Chip(
                  backgroundColor: Colors.blue.shade100,
                  label: Text(
                    i == maxTagsDisplayed ? '+$numExtraTags' : '#$tag',
                  ),
                  visualDensity: VisualDensity.compact,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 6);
              },
              itemCount: min(recipe.tags.length, maxTagsDisplayed + 1),
              scrollDirection: Axis.horizontal),
        ),
      ),
    );
  }
}
