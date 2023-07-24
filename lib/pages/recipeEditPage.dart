import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_archive/components/recipeImage.dart';
import 'package:recipe_archive/components/tagList.dart';
import 'package:recipe_archive/models/recipe.dart';
import 'package:recipe_archive/pages/recipeListPage.dart';

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
  RecipeEditPage(
      {super.key,
      required this.user,
      required this.recipe,
      required this.allTags});

  final User user;
  final Recipe recipe;
  final List<String> allTags;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final Reference storageRef = FirebaseStorage.instance.ref();
  final ImagePicker picker = ImagePicker();

  @override
  _RecipeEditPageState createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  bool _editMode = false;
  late TextEditingController _titleController;
  late TextEditingController _tagController;
  late List<String> _tagList;
  late TextEditingController _notesController;
  late List<String> _imgUrls;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.name);
    _tagController = TextEditingController();
    _tagList = List.from(widget.recipe.tags);
    _notesController = TextEditingController(text: widget.recipe.notes);
    _imgUrls = List.from(widget.recipe.imgUrls);
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

  void deleteImg(String imgUrl) {
    setState(() {
      _imgUrls.remove(imgUrl);
    });
  }

  void handleSave({Function? successCallback}) {
    Recipe saveRecipe = Recipe(
      id: widget.recipe.id,
      name: _titleController.value.text,
      tags: _tagList,
      notes: _notesController.value.text,
      imgUrls: _imgUrls,
    );
    widget.db
        .collection('users')
        .doc(widget.user.uid)
        .collection('recipes')
        .doc(saveRecipe.id)
        .set(saveRecipe.toFirestore())
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
      setState(() {
        _editMode = false;
      });
      if (successCallback != null) {
        successCallback();
      }
    }).onError(
      (error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
      },
    );
  }

  void handleDelete() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete recipe?"),
        content: Text("Are you sure you want to delete this recipe?"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(
              "No",
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.db
                  .collection('users')
                  .doc(widget.user.uid)
                  .collection('recipes')
                  .doc(widget.recipe.id)
                  .delete()
                  .whenComplete(() => ScaffoldMessenger.of(context)
                      .showSnackBar(successSnackBar));
            },
            child: Text("Yes"),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.red.shade600)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            !_editMode
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Delete recipe?"),
                          content: Text(
                              "Are you sure you want to delete this recipe?"),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                "No",
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                widget.db
                                    .collection('users')
                                    .doc(widget.user.uid)
                                    .collection('recipes')
                                    .doc(widget.recipe.id)
                                    .delete()
                                    .then((value) => Navigator.pop(context));
                                Navigator.pop(context, true);
                              },
                              child: Text("Yes"),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.red.shade600)),
                            )
                          ],
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            _editMode
                ? IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: handleSave,
                    tooltip: 'Save',
                  )
                : IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _editMode = true;
                      });
                    },
                    tooltip: 'Edit',
                  ),
          ],
          title: TextFormField(
            controller: _titleController,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              enabledBorder: _editMode ? titleBorder : InputBorder.none,
              focusedBorder: _editMode ? titleBorder : InputBorder.none,
              isDense: true,
            ),
            readOnly: !_editMode,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _editMode
                    ? TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _tagController,
                          decoration: InputDecoration(
                              hintText: 'Add Tag', prefixText: '#'),
                          onEditingComplete: () =>
                              addTagValueToList(_tagController.value.text),
                        ),
                        suggestionsCallback: (pattern) {
                          return widget.allTags.where((tag) =>
                              !_tagList.contains(tag) &&
                              contains(tag, pattern));
                        },
                        hideOnEmpty: true,
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text('#$suggestion'),
                          );
                        },
                        onSuggestionSelected: addTagValueToList,
                        minCharsForSuggestions: 1,
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  height: _editMode ? 8 : 0,
                ),
                TagList(
                    tags: _tagList,
                    onDeleteTag: _editMode ? deleteTagValueFromList : null),
                SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: _notesController,
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 20,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: _editMode
                        ? null
                        : OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                    isDense: true,
                    hintText: 'Notes',
                  ),
                  readOnly: !_editMode,
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    itemBuilder: (context, index) => RecipeImage(
                      imgUrl: _imgUrls[index],
                      onDeleteImg: _editMode ? deleteImg : null,
                    ),
                    itemCount: _imgUrls.length,
                    separatorBuilder: (context, index) => SizedBox(
                      width: 8,
                    ),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Capture a photo.
            final XFile? photo = await widget.picker
                .pickImage(source: ImageSource.camera, imageQuality: 25);
            if (photo == null) {
              return;
            }
            final String storagePath = '${widget.user.uid}/${uuid.v4()}.jpg';
            final imageRef = widget.storageRef.child(storagePath);
            imageRef.putFile(File(photo.path)).then(
                  (p0) => setState(
                    () {
                      _imgUrls.add(storagePath);
                    },
                  ),
                );
          },
          child: const Icon(Icons.camera_alt),
        ),
      ),
      onWillPop: () async {
        void popContext() {
          Navigator.pop(context, true);
        }

        if (!_editMode) {
          return true;
        }

        final result = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Save changes?"),
            content: Text("Do you want to save your changes?"),
            actions: [
              ElevatedButton(
                onPressed: () => popContext(),
                child: Text(
                  "No",
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.red.shade600)),
              ),
              ElevatedButton(
                onPressed: () => handleSave(successCallback: popContext),
                child: Text("Yes"),
              )
            ],
          ),
        );
        return result;
      },
    );
  }
}
