import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:recipe_archive/components/tagList.dart';
import 'package:recipe_archive/models/recipe.dart';

const UnderlineInputBorder titleBorder = UnderlineInputBorder(
  borderSide: BorderSide(color: Colors.white),
);

SnackBar successSnackBar = SnackBar(
  backgroundColor: Colors.green.shade600,
  content: const Text('Save Successful!', style: TextStyle(fontSize: 16)),
  duration: const Duration(seconds: 2),
);

SnackBar failureSnackBar = SnackBar(
  backgroundColor: Colors.red.shade600,
  content: const Text('Oops! Something Went Wrong...',
      style: TextStyle(fontSize: 16)),
  duration: const Duration(seconds: 2),
);

class RecipeEditPage extends StatefulWidget {
  RecipeEditPage({super.key, required this.user, required this.recipe});

  final User user;
  final Recipe recipe;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  _RecipeEditPageState createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _tagController;
  late List<String> _tagList;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.name);
    _tagController = TextEditingController();
    _tagList = List.from(widget.recipe.tags);
    _notesController = TextEditingController(text: widget.recipe.notes);
  }

  void addTagValueToList(String newTag) {
    if (!_tagList.contains(newTag)) {
      setState(() {
        _tagList.add(newTag);
      });
    }
    _tagController.clear();
  }

  void deleteTagValueFromList(String deleteTag) {
    setState(() {
      _tagList.remove(deleteTag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Recipe saveRecipe = Recipe(
                id: widget.recipe.id,
                name: _titleController.value.text,
                tags: _tagList,
                notes: _notesController.value.text,
              );
              widget.db
                  .collection('users')
                  .doc(widget.user.uid)
                  .collection('recipes')
                  .doc(saveRecipe.id)
                  .set(saveRecipe.toFirestore())
                  .then(
                    (value) => ScaffoldMessenger.of(context)
                        .showSnackBar(successSnackBar),
                  )
                  .onError(
                    (error, stackTrace) => ScaffoldMessenger.of(context)
                        .showSnackBar(failureSnackBar),
                  );
            },
            tooltip: 'Save',
          ),
        ],
        title: TextFormField(
          controller: _titleController,
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            enabledBorder: titleBorder,
            focusedBorder: titleBorder,
            isDense: true,
          ),
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Add Tag',
                ),
                onEditingComplete: () =>
                    addTagValueToList(_tagController.value.text),
              ),
              suggestionsCallback: (pattern) {
                return ['abc', 'def', 'geh'];
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: addTagValueToList,
              minCharsForSuggestions: 1,
            ),
            SizedBox(
              height: 8,
            ),
            TagList(_tagList, deleteTagValueFromList),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: _notesController,
              keyboardType: TextInputType.multiline,
              maxLines: 15,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                isDense: true,
                hintText: 'Notes',
              ),
            )
          ],
        ),
      ),
    );
  }
}
