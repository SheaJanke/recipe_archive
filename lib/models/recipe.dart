import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = const Uuid();

class Recipe {
  String id;
  List<String> imgUrls;
  String name;
  String notes;
  List<String> tags;

  Recipe({
    String? id,
    this.imgUrls = const [],
    this.name = 'Untitled Recipe',
    this.notes = '',
    this.tags = const [],
  }) : id = id ?? uuid.v4();

  factory Recipe.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Recipe(
      id: data?['id'],
      imgUrls: data?['imgUrls'] is Iterable ? List.from(data?['imgUrls']) : [],
      name: data?['name'],
      notes: data?['notes'],
      tags: data?['tags'] is Iterable ? List.from(data?['tags']) : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "imgUrls": imgUrls,
      "name": name,
      "notes": notes,
      "tags": tags,
    };
  }
}
